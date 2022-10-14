import loadExternalFile from "../load-external-file";

const TippyHook = {
  deadViewCompatible: true,
  mounted() {
    this.run(this.el);
  },
  updated() {
    this.run(this.el);
  },
  run(el) {
    loadExternalFile([
      "https://cdnjs.cloudflare.com/ajax/libs/tippy.js/6.3.7/tippy.min.css",
      "https://cdnjs.cloudflare.com/ajax/libs/popper.js/2.11.5/umd/popper.min.js",
      "https://cdnjs.cloudflare.com/ajax/libs/tippy.js/6.3.7/tippy.umd.min.js",
    ]).then(() => {
      tippy(el);
    });
  },
};

export default TippyHook;
