import loadExternalFile from "../load-external-file";

// https://github.com/rtfpessoa/diff2html#diff2htmlui-usage
// <div phx-hook="DiffHook" data-diff={@diff}></div>
const DiffHook = {
  deadViewCompatible: true,
  mounted() {
    this.run(this.el);
  },
  updated() {
    this.run(this.el);
  },
  run(el) {
    loadExternalFile([
      "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.13.1/styles/github.min.css",
      "https://cdn.jsdelivr.net/npm/diff2html@3.4.19/bundles/css/diff2html.min.css",
      "https://cdn.jsdelivr.net/npm/diff2html@3.4.19/bundles/js/diff2html-ui.min.js",
    ]).then(() => {
      const diffString = el.dataset.diff;
      const configuration = {
        drawFileList: true,
        highlight: true,
        fileListToggle: true,
        fileListStartVisible: true,
      };
      const diff2htmlUi = new Diff2HtmlUI(el, diffString, configuration);
      diff2htmlUi.draw();
      diff2htmlUi.highlightCode();
    });
  },
};

export default DiffHook;
