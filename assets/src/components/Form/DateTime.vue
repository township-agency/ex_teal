<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <DateTimePicker
        :field="field"
        :field-name="field.name"
        :value="value"
        class="w-full form-control form-input form-input-bordered"
        :date-format="pickerFormat"
        :placeholder="placeholder"
        :twelve-hour-time="twelveHourTime"
        @change="handleChange"
      />
    </template>
  </default-field>
</template>
<script>
import DateTimePicker from '../DateTimePicker';
import { FormField, HandlesValidationErrors } from '@/mixins';
import { DateTime } from 'luxon';

export default {
  components: { DateTimePicker },
  mixins: [ HandlesValidationErrors, FormField ],

  computed: {
    format () {
      return this.field.options.format || DateTime.DATETIME_FULL;
    },

    placeholder () {
      return this.field.options.placeholder ||
        DateTime.local().toLocaleString(this.format);
    },

    pickerFormat () {
      return this.field.options.picker_format || 'Y-m-d H:i:S';
    },

    twelveHourTime () {
      return !this.field.options.twenty_four_hour_time || true;
    },

    naiveDateTime () {
      return this.field.options.naive_datetime || false;
    }
  },

  methods: {
    setInitialValue () {
      this.value = this.field.value || '';

      if (this.value !== '') {
        return;
      }
    },

    handleChange (value) {
      if (this.naiveDateTime) {
        const now = DateTime.local();
        const dt = DateTime.fromISO(value).setZone(now.zoneName);
        this.value = `${dt.toFormat('yyyy-MM-dd')}T${dt.toFormat('TT')}`;
        return;
      }
      this.value = value;
    }
  }
};
</script>
