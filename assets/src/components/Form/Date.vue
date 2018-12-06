<template>
  <default-field :field="field" :errors="errors">
    <template slot="field">
      <date-time-picker
        :field="field"
        :name="field.name"
        :value="value"
        :placeholder="placeholder"
        :enable-time="false"
        :enable-seconds="false"
        class="w-full form-control form-input form-input-bordered"
        date-format="Y-m-d"
        @change="handleChange"
      />
    </template>
  </default-field>
</template>
<script>
import DateTimePicker from "../DateTimePicker";
import { FormField, HandlesValidationErrors } from "@/mixins";
import format from "date-fns/format";

export default {
  components: { DateTimePicker },
  mixins: [HandlesValidationErrors, FormField],

  computed: {
    placeholder() {
      return format(new Date(), "YYYY-MM-DD");
    }
  }
};
</script>
