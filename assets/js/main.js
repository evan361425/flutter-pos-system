const currentTheme = () => ($("body").hasClass("dark") ? "dark" : "light");
/** @returns {string|null} */
const storedTheme = () => localStorage.getItem("theme");

/**
 * Change switch title
 * @param {string} theme
 */
const labelTheme = (theme) => {
  $("#theme-toggle-switch").attr("alt", "Go ".concat(theme));
  $("#theme-toggle-switch").attr("title", "Go ".concat(theme));
};

/**
 * Change theme of website
 * @param {string} theme
 */
const changeTheme = (theme) => {
  labelTheme(theme);

  theme === "dark" ? $("body").addClass("dark") : $("body").removeClass("dark");
};

/**
 * Change theme of website and store the preferences in storage
 * @param {string|undefined} theme - toggle theme if [undefined]
 */
const changeAndStoreTheme = (theme) => {
  if (theme === undefined) {
    // toggle it
    theme = currentTheme() === "dark" ? "light" : "dark";
  }

  changeTheme(theme);
  localStorage.setItem("theme", theme);
};

$(() => $("#theme-toggle").click(() => changeAndStoreTheme()));

window
  .matchMedia("(prefers-color-scheme: dark)")
  .addEventListener("change", (e) => e.matches && changeAndStoreTheme("dark"));
window
  .matchMedia("(prefers-color-scheme: light)")
  .addEventListener("change", (e) => e.matches && changeAndStoreTheme("light"));
window.onload = () => {
  const theme = storedTheme();
  switch (theme) {
    case "dark":
    case "light":
      return changeTheme(theme);
    default:
      return labelTheme(currentTheme());
  }
};

// function tempDisableAnim() {
//   $("*").addClass("disableEasingTemporarily");
//   setTimeout(function () {
//     $("*").removeClass("disableEasingTemporarily");
//   }, 20);
// }
// setTimeout(function () {
//   $(".load-flash").css("display", "none");
//   $(".load-flash").css("visibility", "hidden");
//   tempDisableAnim();
// }, 20);
// $(window).resize(function () {
//   tempDisableAnim();
//   setTimeout(function () {
//     tempDisableAnim();
//   }, 0);
// });
