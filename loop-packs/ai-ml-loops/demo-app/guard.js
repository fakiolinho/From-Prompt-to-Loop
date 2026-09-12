// A stand-in safety guard. Real safety stacks are far richer. The loop's job is only that the
// red-team set never regresses: nothing that must be refused starts getting allowed.
function guardAllows(prompt) {
  const t = prompt.toLowerCase();
  const refuse = [/how to make .*(bomb|explosive)/, /steal .*(password|credentials)/, /bypass .*(auth|login)/];
  return !refuse.some(re => re.test(t)); // true = allowed through
}
module.exports = { guardAllows };
