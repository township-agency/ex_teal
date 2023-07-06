<template>
  <default-field
    :field="field"
    :errors="errors"
  >
    <template slot="field">
      <DateTimePicker
        :field="field"
        :field-name="field.name"
        :value="localizedValue"
        class="w-full form-control form-input form-input-bordered"
        :date-format="pickerFormat"
        :placeholder="placeholder"
        :enable-time="false"
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

  data: () => ({ localizedValue: '' }),

  computed: {
    placeholder () {
      return this.field.options.placeholder ||
        DateTime.local().toLocaleString(this.format);
    },

    pickerFormat () {
      return this.field.options.picker_format || 'Y-m-d';
    }
  },

  methods: {
    setInitialValue () {
      this.value = this.field.value || '';

      if (this.value !== '') {
        this.localizedValue = this.fromUTC(this.value);
      }
    },

    handleChange (value) {
      this.value = value;
      this.localizedValue = this.fromUTC(this.value);
    },

    fromUTC (value) {
      return DateTime.fromISO(this.value).toLocaleString(DateTime.DATE_FULL);
    }
  }
};
</script>
