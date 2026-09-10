---
name: teacher-kit
description: >
  완성된 신현중 정보 수업 활동지(output/dataN.html 계열)에서 교사용 자료(진행률
  위젯 등 학생 전용 UI를 뺀 교사용 HTML + 빈칸이 정답으로 채워진 PDF)를 만드는
  루틴의 진입점. teacher-kit-generator 서브에이전트에 넘긴다.
  "교사용 파일도 만들어줘", "정답 PDF로 뽑아줘", "교사용으로 다듬어줘" 류에 사용.
  학생용 활동지를 새로 만드는 건 routine_1이, 완성본 디자인/구성 점검은
  worksheet-audit이 맡는다 — 이 스킬은 교사용 파생 자료 생성 전용.
---

# teacher-kit — 교사용 자료 생성 루틴 (진입점)

이 루틴은 **`teacher-kit-generator` 서브에이전트**가 실행한다.
(`.claude/agents/teacher-kit-generator.md`)

## 실행 방법

`Agent` 도구로 `subagent_type: "teacher-kit-generator"`를 호출한다. `prompt`에는
대상 파일(보통 `output/CURRENT.md`가 가리키는 파일, 또는 사용자가 지정한
`output/dataN.html`)을 담는다.

학생용 HTML의 내용(문제·빈칸)은 그대로 두고, 교사용 HTML과 정답 PDF만 새로 만든다.
정답을 알 수 없는 항목이 있으면 지어내지 않고 사용자에게 되묻는다.

## 핵심 규칙

- 학생용 파일은 건드리지 않는다.
- `output/<슬러그>.answers.md`가 있으면 그 값을 그대로 옮겨 쓴다(재계산 금지).
- 완료 후 활성 파일 경로만 간단히 보고한다.
