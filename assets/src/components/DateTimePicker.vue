<template>
  <input
    ref="datePicker"
    :disabled="disabled"
    :class="{ '!cursor-not-allowed': disabled }"
    :value="value"
    :name="field.name"
    :placeholder="placeholder"
    type="text"
  >
</template>

<script>
import flatpickr from 'flatpickr';
import { DateTime } from 'luxon';

export default {
  props: {
    field: {
      type: Object,
      required: true
    },
    value: {
      type: String,
      required: false,
      default: null
    },
    placeholder: {
      type: String,
      default: () => {
        return DateTime.local().toLocaleString(DateTime.DATETIME_MED);
      }
    },
    disabled: {
      type: Boolean,
      default: false
    },
    dateFormat: {
      type: String,
      default: 'Y-m-d H:i:S'
    },
    twelveHourTime: {
      type: Boolean,
      default: true
    },
    enableTime: {
      type: Boolean,
      default: true
    },
    enableSeconds: {
      type: Boolean,
      default: true
    }
  },

  data: () => ({ flatpickr: null }),

  mounted () {
    this.$nextTick(() => {
      this.flatpickr = flatpickr(this.$refs.datePicker, {
        enableTime: this.enableTime,
        enableSeconds: this.enableSeconds,
        onClose: this.onChange,
        dateFormat: 'Z',
        allowInput: true,
        altInput: true,
        altFormat: this.dateFormat,

        time_24hr: !this.twelveHourTime
      });
    });
  },

  beforeDestroy () {
    this.flatpickr.destroy();
  },

  methods: {
    onChange () {
      this.$emit('change', this.$refs.datePicker.value);
    }
  },
};
</script>
