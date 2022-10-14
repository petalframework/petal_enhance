const ClipboardHook = {
  deadViewCompatible: true,

  mounted() {
    this.init(this.el);
  },

  updated() {
    this.init(this.el);
  },

  init(el) {
    if (navigator.clipboard) {
      el.addEventListener("click", function () {
        copyToClipboard(el);
        toggleSvgs(el);
      });

      el.querySelector("svg").classList.remove("hidden");
    }
  },
};

function toggleSvgs(el) {
  [...el.querySelectorAll("svg")].map((svgEl) =>
    svgEl.classList.toggle("hidden")
  );
}

function copyToClipboard(el) {
  let textToCopy = el.dataset.content;

  if (navigator.clipboard) {
    navigator.clipboard.writeText(textToCopy);
  } else {
  }

  setTimeout(() => {
    toggleSvgs(el);
  }, 1000);
}

export default ClipboardHook;
