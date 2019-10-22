<template>
  <input
    ref="datePicker"
    :disabled="disabled"
    :dusk="field.attribute"
    :class="{ '!cursor-not-allowed': disabled }"
    :value="value"
    :name="field.name"
    :placeholder="placeholder"
    type="text"
  >
</template>

<script>
import flatpickr from 'flatpickr';
import format from 'date-fns/format';

export default {
  props: {
    field: {
      type: Object,
      required: true
    },
    value: {
      type: [ Date, String ],
      required: false,
      default: format(new Date(), 'YYYY-MM-DD')
    },
    placeholder: {
      type: String,
      default: () => {
        return format(new Date(), 'YYYY-MM-DD kk:mm:ss');
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
      default: false
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
        dateFormat: this.dateFormat,
        allowInput: true,
        time_24hr: !this.twelveHourTime
      });
    });
  },

  methods: {
    onChange () {
      this.$emit('change', this.$refs.datePicker.value);
    }
  }
};
</script>
