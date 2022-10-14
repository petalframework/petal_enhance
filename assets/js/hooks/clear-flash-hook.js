/*
 * This is a simple hook to ensure that if the Notification
 * component dispatches a "clear-flash" event that it will
 * be correctly handled when used as part of a live view.
 *
 * The Notification component uses AlpineJS to define behavior
 * such as when the progress bar is shown and when to hide the
 * notification. Whenever the notification is hidden the
 * "clear-flash" element is dispatched.
 */
const ClearFlashHook = {
  mounted() {
    this.el.addEventListener("clear-flash", () => {
      this.el.remove();
      this.pushEvent("lv:clear-flash", {}, () => {});
    });
  },
};

export default ClearFlashHook;
