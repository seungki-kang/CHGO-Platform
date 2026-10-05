# JL-CORE-001 JesusLife Canonical Source Registry 1.0

Status: CANDIDATE FOR AUTHOR REVIEW  
Platform: JESUSLIFE ONE  
Meaning authority: JesusLife Canonical  
Technical consumer: CHGO Engine and Life Diary Runtime

## 1. Purpose

This registry connects the authorized JesusLife sources to stable canonical concepts without storing unrestricted textbook or workbook content in the repository. It protects provenance, meaning, wording, theological interpretation, rights, and future migration.

## 2. Source hierarchy

1. The authorized JesusLife textbook and workbook are primary authored sources.
2. The CHGO Constitution and Core Philosophy govern platform-wide interpretation.
3. Author-approved clinical and operational refinements may extend a source formulation when they do not reverse its meaning.
4. Runtime labels, translations, summaries, AI responses, and UI copy are projections and never outrank the Canonical layer.

## 3. Admitted sources

| Source ID | Source | SHA-256 | Repository policy |
|---|---|---|---|
| SRC-JL-TEXTBOOK | `01-02. 지저스라이프 내지.pdf` | `44661a2cffdd32c0fd28121b181b48e42e5dee64287da51d95c742a76f3d1f4b` | Provenance only; raw source excluded |
| SRC-JL-WORKBOOK | `2024_문답지06_ebook_3000_0312.pdf` | `4067c500d828f47bbe69595b5be3f62950c7db1133cfe2bd550fda040fe87cf3` | Provenance only; raw source excluded |
| SRC-CHGO-CONTEXT | Master Context 1.0 | `1a8511fc5f16fc894bf0c17a18332dd89efe7a818c8db9f211d09f99eac252c6` | Admitted governance source |

## 4. Stable canonical objects

| Canonical ID | Meaning | Source basis | Runtime use |
|---|---|---|---|
| JL-LD-Q01 | 오늘의 사건과 내면 반응에서 옛사람을 발견한다. | Textbook, Life Diary Q1 | Narrative first, then category selection |
| JL-LD-Q02 | 발견한 옛사람이 그리스도와 함께 십자가에서 처리된 복음의 사실을 고백한다. | Rom 6:6; Gal 2:20; textbook Cross/Old Person/Life Diary sections | Fixed representative confession plus explanation |
| JL-LD-Q03 | 오늘 나에게 이루어진 하나님 나라와 성령의 열매를 발견하고 누린다. | Textbook, Life Diary Q3 | Inner/community branch |
| JL-LD-Q04 | 다른 사람의 옛사람을 판단과 저항 없이 긍휼로 바라본다. | Textbook, Life Diary Q4 | Optional return to Q1 and Q2 |
| JL-LD-Q05 | 성령의 도우심과 교제를 돌아본다. | Rom 8:26; textbook | Communion reflection |
| JL-LD-Q06 | 구체적인 감사를 세 가지 이상 기록한다. | Textbook | Gratitude entries |
| JL-LD-Q07 | 오늘의 깨달음을 삶의 실천으로 연결한다. | Textbook | Action commitment |
| JL-OLD-01..07 | 옛사람의 일곱 범주 | Author-approved Life Diary formulation | Multi-select controlled vocabulary |
| JL-FRUIT-01..09 | 성령의 아홉 열매 | Gal 5:22–23 and author-approved terminology | Controlled vocabulary |

## 5. Q2 canonical confession and meaning

### Representative confession

> 예수님과 함께 십자가에 못 박혀 죽었습니다

This is a canonical representative confession. Its exact Korean wording is preserved in the Korean runtime, but the purpose is understanding, faith, confession, and embodiment—not mechanical repetition.

### Meaning

- It does not deny, despise, or erase the person created by God.
- It does not command emotional suppression, self-punishment, or self-harm.
- It confesses the gospel reality that the old person's dominion ended through union with Christ.
- The user does not manufacture another crucifixion; the user applies an accomplished gospel reality to today's discovered response.
- The movement is not death alone: the confession leads to life in Christ, the Spirit's guidance, the Spirit's fruit, and the present kingdom of God.

### Biblical basis and interpretive priority

1. Romans 6:6 directly grounds the old person being crucified with Christ.
2. Galatians 2:20 directly grounds union with Christ and Christ living in the believer.
3. 1 Corinthians 15:31 is retained as a supporting JesusLife formation text. Its immediate context includes Paul's repeated exposure to death for the gospel; it must not be used alone to prove repeated re-crucifixion.

### Daily application rule

The cross is an accomplished event; its recognition and application occur in daily life. “날마다 죽노라” must never be presented as self-hatred or as a requirement to recreate Christ's finished work.

### Runtime explanatory copy

Long form:

> 이 고백은 나 자신을 부정하거나 정죄하는 말이 아닙니다. 예수 그리스도와 연합한 사람에게 옛사람의 지배가 십자가에서 끝났다는 복음의 사실을 고백하는 것입니다. 오늘 발견한 옛사람을 내가 억지로 없애려 하지 않고, 예수님과 함께 십자가에 못 박힌 사실을 믿음으로 바라봅니다. 이제 내 안에 계신 예수님의 생명과 성령의 인도하심을 따라 살아갑니다.

Short form:

> 오늘 발견한 옛사람은 나의 참된 정체성이 아닙니다. 옛사람의 지배는 그리스도와 함께 십자가에서 끝났습니다. 이제 내 안에 계신 예수님의 생명으로 살아갑니다.

## 6. Q2 governance state

The confession is not classified as an unexplained “locked sentence.” It is governed as:

- `canonical_status`: `REPRESENTATIVE_CONFESSION`
- `wording_policy`: `EXACT_KO_WITH_EXPLANATION`
- `interaction_policy`: `COPY_OR_CONFESS_WITH_UNDERSTANDING`
- `translation_policy`: `MEANING_REVIEW_REQUIRED`
- `revision_authority`: `AUTHOR_AND_CANONICAL_GOVERNANCE`

UI teams may change layout and explanatory presentation. They may not silently alter the confession, reverse its meaning, remove the new-life movement, or turn it into self-condemnation.

## 7. Versioning and change control

- Canonical IDs never contain consumer brand names.
- Display names and explanatory copy may evolve independently.
- Any meaning change requires an explicit change object, author review, impact analysis, migration note, and changelog entry.
- Translation requires theological equivalence review, not word-for-word automation alone.
- Source quotations beyond permitted repository excerpts remain outside Git.

## 8. Acceptance gate

This candidate becomes approved when the author confirms:

1. the Q1–Q7 meanings;
2. the seven old-person terms;
3. the nine fruit terms;
4. the Q2 representative confession and explanation;
5. the source and copyright boundaries.

