"""Read-only source registration checks. No HTTP, database, device or build execution."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[3]
DOCS = ROOT / "docs/开发任务"


def read(path):
    return path.read_text(encoding="utf-8-sig").replace("\r\n", "\n")


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":")).encode()


def check():
    supplement = json.loads(read(DOCS / "26-SC-20261017-开始培养接口增补.json"))
    baseline = json.loads(read(DOCS / "26-全系统接口契约骨架清单.json"))
    assert baseline["summary"]["total"] == 534
    assert hashlib.sha256(canonical(baseline["summary"])).hexdigest() == supplement["baseline"]["summarySha256"]
    assert any(item["id"] == supplement["supplementId"] for item in baseline["contract_supplements"])
    frozen_ids = {item["interface_id"] for item in baseline["interfaces"]}
    routes = set()
    for entry in supplement["newHttp"] + supplement["existingHttpExtensions"]:
        key = entry["method"], entry["path"]
        assert key not in routes, key
        routes.add(key)
        controller = read(ROOT / entry["controller"])
        prefix = re.search(r'@RequestMapping\("([^"]+)"\)', controller).group(1)
        method = re.search(r'((?:\s*@[\w.]+(?:\([^)]*\))?\s*)+)public\s+AjaxResult\s+'
                           + re.escape(entry["controllerMethod"]) + r'\(', controller)
        assert method, entry["id"]
        annotations = method.group(1)
        mapping = re.search(r'@(Get|Post)Mapping\(\s*(?:value\s*=\s*)?"([^"]*)"', annotations)
        assert mapping, entry["id"]
        assert mapping.group(1).upper() == entry["method"], entry["id"]
        assert prefix + mapping.group(2) == entry["path"], entry["id"]
        assert f'@RequiresPermissions("{entry["permission"]}")' in annotations, entry["id"]
        assert ("@ManagementGuardedWrite" in annotations) == entry["guardedWrite"], entry["id"]
        assert ("@CurrentManagementRevision" in annotations) == entry["currentManagementRevision"], entry["id"]
        if entry["applicationMethod"]:
            service = read(ROOT / entry["applicationService"])
            assert re.search(r'public\s+(?:Object|ActionResult)\s+'
                             + re.escape(entry["applicationMethod"]) + r'\(', service), entry["id"]
        if entry["changeKind"] == "EXTENSION":
            assert entry["id"] in frozen_ids, entry["id"]
        else:
            assert entry["id"] not in frozen_ids, entry["id"]
        assert entry["verification"]["httpVerification"] == "NOT_VERIFIED"

    for entry in supplement["ownerPorts"]:
        interface = re.sub(r'\s+', ' ', read(ROOT / entry["interface"]))
        provider = read(ROOT / entry["provider"])
        for signature in entry["methodSignatures"]:
            assert signature in interface, signature
            name = re.search(r'(\w+)\(', signature).group(1)
            assert re.search(r'\b' + name + r'\s*\(', provider), name
    transport = supplement["transportModels"]
    dto = read(ROOT / transport["source"])
    actual = {m.group(1): re.sub(r'\s+', ' ', m.group(2)).strip()
              for m in re.finditer(r'public record (\w+)\((.*?)\)\s*\{', dto, re.S)}
    assert actual == {entry["name"]: entry["components"] for entry in transport["records"]}
    assert len(supplement["newHttp"]) == 4
    assert len(supplement["existingHttpExtensions"]) == 7
    count = sum(len(item["methodSignatures"]) for item in supplement["ownerPorts"])
    print(f"SC registration static checks passed: frozen total=534; new HTTP=4; existing extensions=7; owner methods={count}; DTO records={len(actual)}. HTTP/MySQL/device NOT_VERIFIED.")


if __name__ == "__main__":
    check()
