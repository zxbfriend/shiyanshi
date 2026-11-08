#!/usr/bin/env node
/**
 * 契约骨架锚点独立重算器（TASK-SYS-SKELETON，包0 新增；M03 方言收口轮 DD-20261001-LEGACY-EXEMPT）。
 *
 * 定位（work4 P1-3 裁决）：这是**测试侧独立重算器**，不是 `_tmp_skelgen/gen/gen26.js` 生产链的替代物。
 * `_tmp_skelgen` 已不在仓库，26 清单与 port-closure-anchor 的原始生成程序不可复现；
 * 本脚本只重算“可由现存三源推导的计数”，并把不可推导的 blocked 裁决当作输入而非输出。
 *
 * 三源与权威划分：
 *   1. docs/开发任务/00-全接口契约骨架清单.json      —— 冻结条目权威：按 module 计 interface 记录数 = frozenTotal
 *   2. port-closure-anchor.json 的 modules.*.blockedIds —— blocked 裁决权威（人工收口决策，不可从 1 推导）
 *   3. skeleton-mXX.json 的 entries[]                —— 门禁面：条目数必须等于 frozenTotal − blockedCount
 *   4. docs/开发任务/26-全系统接口契约骨架清单.json   —— 收口报告面：计数必须由 1/2/3 复现
 *
 * 用法：
 *   node docs/开发任务/tools/gen-skeleton-anchors.mjs          # 只重算并比对（漂移则退出码 1）
 *   node docs/开发任务/tools/gen-skeleton-anchors.mjs --write   # 比对通过后按重算值就地改写计数字段
 *
 * --write 只做定点数值改写（不整文件重排），因此不会把 26 清单 533 条记录格式化重写。
 * 改写后仍必须由 SkeletonAnchorRecomputeContractTest 复验：两者互为独立实现，任一侧被手改都会失配。
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..', '..');
const INV00 = resolve(ROOT, 'docs/开发任务/00-全接口契约骨架清单.json');
const INV26 = resolve(ROOT, 'docs/开发任务/26-全系统接口契约骨架清单.json');
const ANCHOR = resolve(ROOT,
  'futurefab-modules/futurefab-system/src/test/resources/contract/port-closure-anchor.json');
const SKEL = (m) => resolve(ROOT,
  `futurefab-modules/futurefab-system/src/test/resources/contract/skeleton-${m.toLowerCase()}.json`);

const MODES = ['m02', 'm03', 'm04', 'm05', 'm06', 'm07', 'm09'];
const MODULES = MODES.map((s) => s.toUpperCase());
const ALL_MODULES = ['M01'].concat(MODULES);
/** 处置口径轴（route_disposition / disposition），与可用性三轴（wired/legacy/disabled）正交。 */
const DISPS = ['REUSE', 'ADJUST', 'NEW', 'COMPAT', 'DISABLE'];

const json = (p) => JSON.parse(readFileSync(p, 'utf8'));

/** 源1：按 module 统计 00 清单记录数（M01 一并统计，供 26 清单总数复现）。 */
function frozenFromInventory00() {
  const inv = json(INV00);
  const counts = {};
  const dispositions = {};
  for (const rec of inv.interfaces) {
    counts[rec.module] = (counts[rec.module] ?? 0) + 1;
    const d = (dispositions[rec.module] ??= {});
    d[rec.route_disposition] = (d[rec.route_disposition] ?? 0) + 1;
  }
  return {
    counts,
    dispositions,
    total: inv.interfaces.length,
    declaredSummary: inv.summary ?? {},
    declaredInternal: Object.fromEntries(
      Object.entries(inv.modules ?? {}).map(([m, v]) => [m, (v.internal_contracts ?? []).length]),
    ),
  };
}

/** 源3：各模块门禁条目数。 */
function entriesFromSkeletons() {
  const out = {};
  for (const m of MODULES) {
    out[m] = json(SKEL(m.toLowerCase())).entries.length;
  }
  return out;
}

function recompute() {
  const inv = frozenFromInventory00();
  const entries = entriesFromSkeletons();
  const anchorDoc = json(ANCHOR);
  const per = {};
  for (const m of MODULES) {
    const declared = anchorDoc.modules[m] ?? {};
    const blockedIds = declared.blockedIds ?? [];
    const frozen = inv.counts[m] ?? 0;
    per[m] = {
      frozenTotal: frozen,
      blockedCount: blockedIds.length,
      blockedIds,
      gateExpected: frozen - blockedIds.length,
      gateActual: entries[m] ?? 0,
    };
  }
  const sum = (f) => MODULES.reduce((a, m) => a + f(per[m]), 0);
  const totals = {
    frozenNonM01Total: sum((p) => p.frozenTotal),
    blockedTotal: sum((p) => p.blockedCount),
    gateEntriesExpected: sum((p) => p.gateExpected),
    gateEntriesActual: sum((p) => p.gateActual),
    inventoryTotal: inv.total,
    m01Total: inv.counts.M01 ?? 0,
  };
  return { per, totals, declaredAnchor: anchorDoc.anchor, declaredModules: anchorDoc.modules, inv };
}

/** 比对：锚点声明值 vs 重算值 vs 26 清单声明值。 */
function diff(r, inv26) {
  const bad = [];
  for (const m of MODULES) {
    const p = r.per[m];
    const d = r.declaredModules[m] ?? {};
    if (d.frozenTotal !== p.frozenTotal) bad.push(`anchor.${m}.frozenTotal=${d.frozenTotal} 重算=${p.frozenTotal}`);
    if (d.blockedCount !== p.blockedCount) bad.push(`anchor.${m}.blockedCount=${d.blockedCount} 重算=${p.blockedCount}`);
    if (d.gateExpected !== p.gateExpected) bad.push(`anchor.${m}.gateExpected=${d.gateExpected} 重算=${p.gateExpected}`);
    if (JSON.stringify(d.blockedIds ?? []) !== JSON.stringify(p.blockedIds)) bad.push(`anchor.${m}.blockedIds 与 blockedCount 不自洽`);
    if (p.gateActual !== p.gateExpected) bad.push(`skeleton-${m.toLowerCase()}.json 条目=${p.gateActual} 期望=${p.gateExpected}`);
    const c26 = inv26.summary.moduleCounts[m];
    if (c26 !== p.frozenTotal) bad.push(`26.summary.moduleCounts.${m}=${c26} 重算=${p.frozenTotal}`);
  }
  if (r.declaredAnchor.frozenNonM01Total !== r.totals.frozenNonM01Total) {
    bad.push(`anchor.frozenNonM01Total=${r.declaredAnchor.frozenNonM01Total} 重算=${r.totals.frozenNonM01Total}`);
  }
  if (r.declaredAnchor.blockedTotal !== r.totals.blockedTotal) {
    bad.push(`anchor.blockedTotal=${r.declaredAnchor.blockedTotal} 重算=${r.totals.blockedTotal}`);
  }
  if (r.declaredAnchor.gateEntriesExpected !== r.totals.gateEntriesExpected) {
    bad.push(`anchor.gateEntriesExpected=${r.declaredAnchor.gateEntriesExpected} 重算=${r.totals.gateEntriesExpected}`);
  }
  if (inv26.summary.total !== r.totals.inventoryTotal) {
    bad.push(`26.summary.total=${inv26.summary.total} 00清单=${r.totals.inventoryTotal}`);
  }
  if (inv26.summary.moduleCounts.M01 !== r.totals.m01Total) {
    bad.push(`26.summary.moduleCounts.M01=${inv26.summary.moduleCounts.M01} 重算=${r.totals.m01Total}`);
  }
  if (inv26.summary.gateEntries !== r.totals.gateEntriesExpected) {
    bad.push(`26.summary.gateEntries=${inv26.summary.gateEntries} 重算=${r.totals.gateEntriesExpected}`);
  }
  if (inv26.summary.blockedRegistered !== r.totals.blockedTotal) {
    bad.push(`26.summary.blockedRegistered=${inv26.summary.blockedRegistered} 重算=${r.totals.blockedTotal}`);
  }
  const inSource = inv26.summary.skeletonStatusCounts.SKELETON_IN_SOURCE;
  if (inSource !== r.totals.inventoryTotal - r.totals.blockedTotal) {
    bad.push(`26.summary.skeletonStatusCounts.SKELETON_IN_SOURCE=${inSource} 重算=${r.totals.inventoryTotal - r.totals.blockedTotal}`);
  }
  const byMod26 = {};
  for (const rec of inv26.interfaces) byMod26[rec.module] = (byMod26[rec.module] ?? 0) + 1;
  for (const m of MODULES.concat(['M01'])) {
    if (byMod26[m] !== inv26.summary.moduleCounts[m]) {
      bad.push(`26.interfaces[${m}]=${byMod26[m]} 与 summary.moduleCounts=${inv26.summary.moduleCounts[m]} 失配`);
    }
  }
  if (inv26.blockers.length !== r.totals.blockedTotal) {
    bad.push(`26.blockers=${inv26.blockers.length} 重算=${r.totals.blockedTotal}`);
  }

  // 00 清单 summary（含 DISABLE 处置计数）必须由其自身 interfaces 复现（包3 M03-044 登记轮纳入同源面）
  for (const m of ALL_MODULES) {
    const ds = r.inv.declaredSummary[m] ?? {};
    const ac = r.inv.dispositions[m] ?? {};
    const n = r.inv.counts[m] ?? 0;
    if (ds.total !== n) bad.push(`00.summary.${m}.total=${ds.total} 重算=${n}`);
    for (const d of DISPS) {
      if ((ds[d] ?? 0) !== (ac[d] ?? 0)) bad.push(`00.summary.${m}.${d}=${ds[d] ?? 0} 重算=${ac[d] ?? 0}`);
    }
    if (ds.internal_contracts !== (r.inv.declaredInternal[m] ?? 0)) {
      bad.push(`00.summary.${m}.internal_contracts=${ds.internal_contracts} `
        + `重算=00.modules.${m}.internal_contracts.length=${r.inv.declaredInternal[m] ?? 0}`);
    }
  }

  // 26 处置计数须同时等于 26 自身记录与 00 冻结清单（DISABLE 等口径不得只改一侧）
  const disp26 = {};
  for (const rec of inv26.interfaces) disp26[rec.disposition] = (disp26[rec.disposition] ?? 0) + 1;
  const disp00 = {};
  for (const m of ALL_MODULES) {
    for (const [d, v] of Object.entries(r.inv.dispositions[m] ?? {})) disp00[d] = (disp00[d] ?? 0) + v;
  }
  for (const d of DISPS) {
    const declared = inv26.summary.dispositionCounts[d] ?? 0;
    if (declared !== (disp26[d] ?? 0)) bad.push(`26.dispositionCounts.${d}=${declared} 26记录=${disp26[d] ?? 0}`);
    if (declared !== (disp00[d] ?? 0)) bad.push(`26.dispositionCounts.${d}=${declared} 00清单=${disp00[d] ?? 0}`);
  }
  return bad;
}

/** --write：anchor 整文件按重算值生成（1 空格缩进，键序不变）；26 清单只在 summary 区段内定点改数值。 */
function writeBack(r, inv26) {
  const inv00Text = readFileSync(INV00, 'utf8');
  const summaryAt = inv00Text.indexOf('"summary"');
  const summaryStart = inv00Text.indexOf('{', summaryAt);
  const summaryEnd = matchBrace(inv00Text, summaryStart);
  const summary00 = JSON.parse(inv00Text.slice(summaryStart, summaryEnd + 1));
  for (const m of ALL_MODULES) {
    summary00[m].total = r.inv.counts[m] ?? 0;
    for (const d of DISPS) summary00[m][d] = r.inv.dispositions[m]?.[d] ?? 0;
  }
  writeFileSync(INV00, inv00Text.slice(0, summaryStart) + JSON.stringify(summary00, null, 2)
    + inv00Text.slice(summaryEnd + 1));
  const anchorText = readFileSync(ANCHOR, 'utf8');
  const declared = JSON.parse(anchorText);
  const next = {
    generated_from: declared.generated_from,
    modules: {},
    anchor: {
      frozenNonM01Total: r.totals.frozenNonM01Total,
      blockedTotal: r.totals.blockedTotal,
      gateEntriesExpected: r.totals.gateEntriesExpected,
    },
  };
  for (const m of MODULES) {
    const p = r.per[m];
    next.modules[m] = {
      frozenTotal: p.frozenTotal,
      blockedCount: p.blockedCount,
      blockedIds: p.blockedIds,
      gateExpected: p.gateExpected,
    };
  }
  const generated = JSON.stringify(next, null, 1) + '\n';
  if (generated !== anchorText) writeFileSync(ANCHOR, generated);

  const t26 = readFileSync(INV26, 'utf8');
  const start = t26.indexOf('"summary"');
  if (start < 0 || t26.indexOf('"moduleCounts"', start) < 0) throw new Error('26 清单缺 summary/moduleCounts 区段');
  const objStart = t26.indexOf('{', t26.indexOf(':', start) + 1);
  const region = t26.slice(objStart, matchBrace(t26, objStart) + 1);
  const sum = JSON.parse(region);
  for (const m of Object.keys(sum.moduleCounts)) {
    sum.moduleCounts[m] = m === 'M01' ? r.totals.m01Total : r.per[m].frozenTotal;
  }
  sum.total = r.totals.inventoryTotal;
  sum.gateEntries = r.totals.gateEntriesExpected;
  sum.blockedRegistered = r.totals.blockedTotal;
  sum.skeletonStatusCounts.SKELETON_IN_SOURCE = r.totals.inventoryTotal - r.totals.blockedTotal;
  sum.skeletonStatusCounts.BLOCKED_REGISTERED = r.totals.blockedTotal;
  for (const d of DISPS) sum.dispositionCounts[d] = ALL_MODULES.reduce((n, m) => n + (r.inv.dispositions[m]?.[d] ?? 0), 0);
  sum.anchors = {
    total_540: sum.total === 540,
    m01_76: sum.moduleCounts.M01 === 76,
    nonM01_464: r.totals.frozenNonM01Total === 464,
    entries_448_plus_blocked_14: sum.gateEntries + sum.blockedRegistered === r.totals.frozenNonM01Total,
  };
  const rewritten = t26.slice(0, objStart) + JSON.stringify(sum, null, 2) + t26.slice(matchBrace(t26, objStart) + 1);
  if (rewritten !== t26) writeFileSync(INV26, rewritten);
}

/** 返回与 openIdx 处 '{' 配对的 '}' 下标（跳过字符串字面量）。 */
function matchBrace(text, openIdx) {
  let depth = 0;
  let inStr = false;
  for (let i = openIdx; i < text.length; i++) {
    const c = text[i];
    if (inStr) {
      if (c === '\\') i++;
      else if (c === '"') inStr = false;
      continue;
    }
    if (c === '"') inStr = true;
    else if (c === '{') depth++;
    else if (c === '}' && --depth === 0) return i;
  }
  throw new Error('大括号不配对，拒绝改写');
}

const r = recompute();
const inv26 = json(INV26);
const bad = diff(r, inv26);
console.log(JSON.stringify({ per: r.per, totals: r.totals }, null, 1));
if (bad.length && !process.argv.includes('--write')) {
  console.error('锚点/清单计数漂移:\n' + bad.join('\n'));
  process.exit(1);
}
if (process.argv.includes('--write')) {
  // Only derived counters are repairable. Never manufacture/remove contract or blocker records.
  const inv00 = json(INV00);
  const actualIds = inv00.interfaces.map(x => x.interface_id);
  const reportIds = inv26.interfaces.map(x => x.interface_id);
  const structural = MODULES.filter(m => r.per[m].gateActual !== r.per[m].gateExpected);
  if (structural.length || new Set(actualIds).size !== actualIds.length
      || new Set(reportIds).size !== reportIds.length
      || JSON.stringify([...actualIds].sort()) !== JSON.stringify([...reportIds].sort())
      || inv26.blockers.length !== r.totals.blockedTotal) {
    throw new Error('契约条目/blocked裁决未同源，拒绝生成计数: ' + structural.join(','));
  }
  writeBack(r, inv26);
  const remaining = diff(recompute(), json(INV26));
  if (remaining.length) throw new Error('生成后仍有漂移: ' + remaining.join('\n'));
  console.log('已按重算值定点改写 port-closure-anchor.json 与 26 清单计数字段');
} else {
  console.log('同源校验通过（未改写文件；--write 才落盘）');
}
