(window.webpackJsonp=window.webpackJsonp||[]).push([[42],{JSzz:function(e,t,i){"use strict";(function(e){i.d(t,"a",function(){return r});var n=void 0;function s(){s.init||(s.init=!0,n=-1!==function(){var e=window.navigator.userAgent,t=e.indexOf("MSIE ");if(t>0)return parseInt(e.substring(t+5,e.indexOf(".",t)),10);if(e.indexOf("Trident/")>0){var i=e.indexOf("rv:");return parseInt(e.substring(i+3,e.indexOf(".",i)),10)}var n=e.indexOf("Edge/");return n>0?parseInt(e.substring(n+5,e.indexOf(".",n)),10):-1}())}var r={render:function(){var e=this.$createElement;return(this._self._c||e)("div",{staticClass:"resize-observer",attrs:{tabindex:"-1"}})},staticRenderFns:[],_scopeId:"data-v-b329ee4c",name:"resize-observer",methods:{compareAndNotify:function(){this._w===this.$el.offsetWidth&&this._h===this.$el.offsetHeight||(this._w=this.$el.offsetWidth,this._h=this.$el.offsetHeight,this.$emit("notify"))},addResizeHandlers:function(){this._resizeObject.contentDocument.defaultView.addEventListener("resize",this.compareAndNotify),this.compareAndNotify()},removeResizeHandlers:function(){this._resizeObject&&this._resizeObject.onload&&(!n&&this._resizeObject.contentDocument&&this._resizeObject.contentDocument.defaultView.removeEventListener("resize",this.compareAndNotify),delete this._resizeObject.onload)}},mounted:function(){var e=this;s(),this.$nextTick(function(){e._w=e.$el.offsetWidth,e._h=e.$el.offsetHeight});var t=document.createElement("object");this._resizeObject=t,t.setAttribute("aria-hidden","true"),t.setAttribute("tabindex",-1),t.onload=this.addResizeHandlers,t.type="text/html",n&&this.$el.appendChild(t),t.data="about:blank",n||this.$el.appendChild(t)},beforeDestroy:function(){this.removeResizeHandlers()}};var o={version:"0.4.5",install:function(e){e.component("resize-observer",r),e.component("ResizeObserver",r)}},d=null;"undefined"!=typeof window?d=window.Vue:void 0!==e&&(d=e.Vue),d&&d.use(o)}).call(this,i("yLpj"))}}]);