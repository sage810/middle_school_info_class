---
name: worksheet-audit
description: >
  이미 만든 신현중 정보 수업 활동지(output/dataN.html 계열, "신현중학교 정보" 레트로 창 UI)를
  guide/ 7문서(activity guide · activity · build · design · google embed rules · pdf download ·
  pdf submit button) 기준으로 점검하고 어긋난 부분만 최소 diff 로 고치는 검수 루틴의 진입점.
  특히 색 밸런스(design.md §2.1 토큰 · §3.5 카드 틴트 · §4.1 accent 8색 순환 · 예비 파스텔)를
  최우선으로 본다. worksheet-audit 서브에이전트에 넘긴다.
  "guide 문서에 맞게 만들어졌는지 확인", "색깔 조화롭게 / 밸런스 맞춰", "활동지 점검·검수·다듬기",
  "완성본 정리", data5 같은 활동지 마무리 점검, /msinfo 8단계 이후 마감 점검에 사용.
  새 활동을 처음부터 만드는 건 /msinfo(worksheet-routine)이 맡는다.
---

# worksheet-audit — 완성 활동지 점검·색 정리 루틴 (진입점)

이 루틴은 **`worksheet-audit` 서브에이전트**가 실행한다.
(`.claude/agents/07-worksheet-audit/AGENT.md` — guide 7문서 대조 + 색 밸런스 검수 + 최소 diff 수정.)

## 실행 방법

`Agent` 도구로 `subagent_type: "worksheet-audit"` 를 호출한다. `prompt` 에는 **점검 대상 파일**
(보통 `output/dataN.html`)과 사용자가 특별히 신경 쓰는 부분(예: "색 밸런스", "가독성",
"형성평가 피드백")을 담는다.

에이전트는 어긋난 것만 고치고, **무엇이 guide 의 어느 조항에 어긋났고 어떻게 바꿨는지**를
정리해 돌려준다. 예시 문구 교체·색 계열 선택처럼 사람 판단이 필요한 지점은 되묻는다.

## 점검 순서 요약 (상세는 에이전트 문서)

| # | 무엇을 | 근거 |
|---|---|---|
| 0 | guide 7문서 정독 | design / activity guide / build / google embed rules / pdf download·submit / activity |
| 1 | **색 밸런스** — 미션 accent 8색 순환, 카드 틴트, 콜아웃 온도(냉/난) 통일, 대비 ≥ 4.5:1 | design.md §2.1·§3.5·§3.6·§4.1·§7 |
| 2 | 구조·컴포넌트 — 유일 `aria-label`/`data-*`, 정답 근거·비노출, 오답 보기별 해설, 외부 리소스 0, head/`<x-dc>` 불변, savePdf hide 목록 | activity guide §1·§2 / build.md / google embed rules / pdf 문서 |
| 3 | 검증 — `<div>` 균형, 미치환 `{{ }}`, Chrome 헤드리스 dump-dom 하이드레이션(이 환경 Edge 불가), 필요 시 print-to-pdf | — |
| 4 | 고친 것 요약 반환 · 새 활동이면 `activity.md` 기록 · 커밋은 호출자 규칙대로 | CLAUDE.md |

## 핵심 규칙

- **새로 만들지 않는다.** 같은 파일만 `Edit`, 최소 diff. 멀쩡한 순환·틴트는 손대지 않는다.
- accent 는 §4.1 8색(aqua·blue·yellow·purple·mint·lilac·salmon·olive) 순환.
  순환에서 빼는 카드는 **예비 파스텔** `--sage #c9e4dc` · `--sky-2 #b8d8e8` · `--moss #d4e0b0` ·
  `--rose-dust #e8c4c4` · `--peri #c4cce8` (design.md §2.1·§4.1) 에서 고른다.
- 한 미션 안의 박스·표·콜아웃은 그 미션 accent 와 같은 온도. 냉색 활동지에 난색 박스 하나만
  튀면 냉색 변형으로 교체. 새 색·radius·서체 만들지 않는다.
- 외부 리소스 0, 이미지 전부 base64. `<head>` 인라인 블록·`<x-dc>` 골격 불변.
