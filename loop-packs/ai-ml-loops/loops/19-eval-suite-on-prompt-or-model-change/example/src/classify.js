// A tiny deterministic intent classifier. Stands in for "your prompt or model".
// The eval loop's job is to keep its accuracy at or above the baseline. Offline, no network.
function classify(utterance) {
  const t = String(utterance).toLowerCase();
  if (/\b(hi|hello|hey|good morning)\b/.test(t)) return 'greeting';
  if (/\b(bye|goodbye|see you|that's all|that is all)\b/.test(t)) return 'goodbye';
  if (/\b(balance|how much.*(have|left)|my funds)\b/.test(t)) return 'check_balance';
  if (/\b(transfer|send money|move .* to)\b/.test(t)) return 'transfer';
  if (/\b(cancel|stop my|close my account)\b/.test(t)) return 'cancel';
  if (/\b(help|support|agent|human|speak to someone)\b/.test(t)) return 'help';
  return 'unknown';
}
module.exports = { classify };
