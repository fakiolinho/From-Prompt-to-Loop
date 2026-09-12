# Where these loops fit

## Building the product, or operating it

Loop engineering went mainstream the moment the people who build these tools said it out loud.
Boris Cherny, who built Claude Code, and Peter Steinberger put it on the map. Then Andrew Ng laid
out the three loops he uses to take a product from zero to one:

- an agentic coding loop that writes and tests against a spec,
- a developer feedback loop where a human steers after seeing the result,
- an external feedback loop where real users reshape the vision.

Those three loops build a product. The thirty five here are the next chapter. They keep a product
alive after it ships.

> The industry worked out the loops that build. These are the loops that operate.

## Same shape, one shift over

An operational loop is that same agentic coding loop with two things bolted on.

**The check is its eval.** It answers one question, is there work, before a single token is
spent.

**The approved PR is its feedback gate.** A human still says yes before anything merges.

Loop 23, growing your eval set from real production failures, and the cost and anomaly loops, are
Ng's external feedback loop wired straight into the machine.

## The only real difference is the clock

His loops run in minutes to hours, while you sit in the chair and watch. These run nightly, on
every deploy, every Monday morning, whether you are in the chair or not.

Same shape. Different shift.

---

The full version opens the field guide,
**[From Prompt to Loop](../From-Prompt-to-Loop_The-Warship-CTO.pdf)**, in the root of this repo.

---

[← Operating a fleet](06-operating.md) · [Contents](../README.md)

**The 35 loops:** [Engineering](../loop-packs/engineering-loops/LOOPS.md) · [Cloud](../loop-packs/cloud-loops/LOOPS.md) · [AI and ML](../loop-packs/ai-ml-loops/LOOPS.md) · [QA](../loop-packs/qa-loops/LOOPS.md)
