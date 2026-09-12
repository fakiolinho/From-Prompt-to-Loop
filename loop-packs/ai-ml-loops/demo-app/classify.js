// A tiny rule-based intent classifier. Stands in for your prompt or model.
function classify(u) {
  const t = u.toLowerCase();
  if (/\b(hi|hello|hey|good morning)\b/.test(t)) return 'greeting';
  if (/\b(bye|goodbye|see you)\b/.test(t)) return 'farewell';
  if (/\b(balance|how much|account)\b/.test(t)) return 'check_balance';
  if (/\b(transfer|send|wire|pay)\b/.test(t)) return 'transfer';
  if (/\b(help|support|agent|human|representative)\b/.test(t)) return 'support';
  return 'unknown';
}
module.exports = { classify };
