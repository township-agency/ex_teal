<script>
import { Bar, mixins } from 'vue-chartjs';
import '@/util/chart-adapter';
const { reactiveProp } = mixins;
export default {
  extends: Bar,
  mixins: [ reactiveProp ],
  props: {
    options: {
      type: Object,
      required: true
    }
  },

  watch: {
    options () {
      this.$data._chart.destroy();
      this.renderChart(this.chartData, this.options);
    }
  },

  mounted () {
    this.renderChart(this.chartData, this.options);
  }
};
</script>