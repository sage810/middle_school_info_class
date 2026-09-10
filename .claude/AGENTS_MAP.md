# 에이전트 지도

`.claude/agents/` 안의 폴더는 이름에 적힌 번호가 워크플로우 순서를 보여주며, 각 폴더의 `AGENT.md`가 에이전트 정의입니다. 폴더로 바꾸어도 각 문서의 frontmatter에 있는 호출용 `name`은 기존 값을 그대로 유지합니다.

## 활동지 제작 순서

| 순서 | 실제 파일 | 호출용 name | 역할과 워크플로우 위치 |
|---|---|---|---|
| 00 | `.claude/agents/00-worksheet-routine/AGENT.md` | `worksheet-routine` | 전체 활동지 제작 흐름을 지휘하고 다음 단계의 에이전트를 연결하는 시작점입니다. |
| 01 | `.claude/agents/01-idea-agent/AGENT.md` | `idea-agent` | 수업 목표와 활동 흐름, 데이터와 정답키를 정해 전체 기획 초안을 만드는 단계입니다. |
| 02 | `.claude/agents/02-activity-agent/AGENT.md` | `activity-agent` | 개별 활동의 유형, 문항, 정답, 피드백과 사용 방법을 구체화하는 단계입니다. |
| 03 | `.claude/agents/03-design-agent/AGENT.md` | `design-agent` | 활동 설계를 기존 디자인 규칙과 화면 구성 요소에 연결하는 단계입니다. |
| 04 | `.claude/agents/04-builder-agent/AGENT.md` | `builder-agent` | 확정된 내용과 디자인 지시서를 하나의 학생용 HTML 활동지로 조립하고 수정하는 단계입니다. |
| 05 | `.claude/agents/05-student-test-agent/AGENT.md` | `student-test-agent` | 완성된 학생용 활동지를 학생 관점에서 입력, 채점, 저장, 출력과 화면 동작으로 시험하는 단계입니다. |
| 06 | `.claude/agents/06-teacher-kit-generator/AGENT.md` | `teacher-kit-generator` | 학생용 완성본에서 교사용 HTML과 정답 PDF를 파생하는 단계입니다. |
| 07 | `.claude/agents/07-worksheet-audit/AGENT.md` | `worksheet-audit` | 완성본을 전체 규칙, 디자인, 인쇄와 접근성 기준으로 최종 점검하는 단계입니다. |

## 보조 에이전트

| 번호 | 실제 파일 | 호출용 name | 역할과 워크플로우 위치 |
|---|---|---|---|
| 90 | `.claude/agents/90-file-cataloger/AGENT.md` | `file-cataloger` | 새 파일이나 큰 변경이 생겼을 때 이 지도와 `PROJECT_MAP.md`를 갱신하는 문서 관리 담당입니다. |
| 91 | `.claude/agents/91-skill-recorder/AGENT.md` | `skill-recorder` | 반복해서 쓸 만한 새 작업 방식을 찾아 스킬이나 에이전트로 기록할지 제안하는 담당입니다. |

00~07은 활동지 제작의 기본 실행 순서이고, 90~91은 제작 흐름을 보조합니다. 사용자가 특정 에이전트를 직접 호출할 때도 파일명은 이 번호가 붙은 실제 이름을 사용하며, 문서 안의 frontmatter `name`은 호출용 식별자로 그대로 둡니다.
