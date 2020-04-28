<template>
  <div class="date-field-filter inline-flex">
    <DateTimePicker
      :field-name="filter.field"
      :value="filter.operand"
      class="w-full form-control field-filter-operand-input group-hover:rounded-none"
      :date-format="pickerFormat"
      :placeholder="placeholder"
      @change="setOperand"
    />
  </div>
</template>
<script>
import DateTimePicker from '../DateTimePicker';
import { DateTime } from 'luxon';

export default {
  components: { DateTimePicker },

  props: {
    filter: {
      required: true,
      type: Object
    },
    fieldFilter: {
      required: true,
      type: Object
    },

  },

  computed: {
    placeholder () {
      return this.fieldFilter.placeholder ||
        DateTime.local().toLocaleString(this.format);
    },

    pickerFormat () {
      return this.fieldFilter.picker_format || 'Y-m-d';
    }
  },
  
  methods: {
    setOperand (val) {
      const dt = DateTime.fromISO(val);
      this.$emit('change', { ...this.filter, operand: dt.toISO(), valid: true });
    }
  }
};
</script>