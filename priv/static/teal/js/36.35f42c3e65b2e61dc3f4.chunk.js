(window.webpackJsonp=window.webpackJsonp||[]).push([[36],{H8ri:function(t,a,e){"use strict";function r(t,a){if(a){var e=this.$data._chart,r=t.datasets.map(function(t){return t.label}),s=a.datasets.map(function(t){return t.label}),n=JSON.stringify(s);JSON.stringify(r)===n&&a.datasets.length===t.datasets.length?(t.datasets.forEach(function(t,r){var s=Object.keys(a.datasets[r]),n=Object.keys(t),i=s.filter(function(t){return"_meta"!==t&&-1===n.indexOf(t)});for(var h in i.forEach(function(t){delete e.data.datasets[r][t]}),t)t.hasOwnProperty(h)&&(e.data.datasets[r][h]=t[h])}),t.hasOwnProperty("labels")&&(e.data.labels=t.labels,this.$emit("labels:update")),t.hasOwnProperty("xLabels")&&(e.data.xLabels=t.xLabels,this.$emit("xlabels:update")),t.hasOwnProperty("yLabels")&&(e.data.yLabels=t.yLabels,this.$emit("ylabels:update")),e.update(),this.$emit("chart:update")):(e&&(e.destroy(),this.$emit("chart:destroy")),this.renderChart(this.chartData,this.options),this.$emit("chart:render"))}else this.$data._chart&&(this.$data._chart.destroy(),this.$emit("chart:destroy")),this.renderChart(this.chartData,this.options),this.$emit("chart:render")}var s={reactiveData:{data:function(){return{chartData:null}},watch:{chartData:r}},reactiveProp:{props:{chartData:{type:Object,required:!0,default:function(){}}},watch:{chartData:r}}},n=e("MO+k"),i=e.n(n);function h(t,a){return{render:function(t){return t("div",{style:this.styles,class:this.cssClasses},[t("canvas",{attrs:{id:this.chartId,width:this.width,height:this.height},ref:"canvas"})])},props:{chartId:{default:t,type:String},width:{default:400,type:Number},height:{default:400,type:Number},cssClasses:{type:String,default:""},styles:{type:Object},plugins:{type:Array,default:function(){return[]}}},data:function(){return{_chart:null,_plugins:this.plugins}},methods:{addPlugin:function(t){this.$data._plugins.push(t)},generateLegend:function(){if(this.$data._chart)return this.$data._chart.generateLegend()},renderChart:function(t,e){this.$data._chart&&this.$data._chart.destroy(),this.$data._chart=new i.a(this.$refs.canvas.getContext("2d"),{type:a,data:t,options:e,plugins:this.$data._plugins})}},beforeDestroy:function(){this.$data._chart&&this.$data._chart.destroy()}}}var d=h("bar-chart","bar"),c=(h("horizontalbar-chart","horizontalBar"),h("doughnut-chart","doughnut")),u=h("line-chart","line");h("pie-chart","pie"),h("polar-chart","polarArea"),h("radar-chart","radar"),h("bubble-chart","bubble"),h("scatter-chart","scatter");e.d(a,"a",function(){return d}),e.d(a,"b",function(){return c}),e.d(a,"c",function(){return u}),e.d(a,"d",function(){return s})}}]);