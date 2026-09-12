// Example Playwright test. Locators come from selectors.example.json. When the app moves an element,
// loop 29 updates that file (a locator fix) and opens a PR. It never edits the expect() lines.
const { test, expect } = require('@playwright/test');
const sel = require('./selectors.example.json');
test('user can reach checkout', async ({ page }) => {
  await page.goto(process.env.BASE_URL);
  await page.click(sel.searchInput);
  await page.click(sel.cartIcon);
  await page.click(sel.checkoutButton);
  await expect(page.getByText('Order summary')).toBeVisible(); // assertion: never auto-healed
});
