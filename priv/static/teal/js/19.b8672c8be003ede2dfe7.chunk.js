(window.webpackJsonp=window.webpackJsonp||[]).push([[19],{"Gu+u":function(e,t){var n=[],r=[],s="insert-css: You need to provide a CSS string. Usage: insertCss(cssString[, options]).";function o(e,t){if(t=t||{},void 0===e)throw new Error(s);var o,i=!0===t.prepend?"prepend":"append",d=void 0!==t.container?t.container:document.querySelector("head"),p=n.indexOf(d);return-1===p&&(p=n.push(d)-1,r[p]={}),void 0!==r[p]&&void 0!==r[p][i]?o=r[p][i]:(o=r[p][i]=function(){var e=document.createElement("style");return e.setAttribute("type","text/css"),e}(),"prepend"===i?d.insertBefore(o,d.childNodes[0]):d.appendChild(o)),65279===e.charCodeAt(0)&&(e=e.substr(1,e.length)),o.styleSheet?o.styleSheet.cssText+=e:o.textContent+=e,o}e.exports=o,e.exports.insertCss=o}}]);