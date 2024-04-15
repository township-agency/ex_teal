<template>
  <div class="flex justify-center flex-1 items-center flex-col text-black">
    <p class="flex items-center text-4xl">
      {{ formattedValue }}
      <span
        v-if="suffix"
        class="ml-2 text-sm font-bold text-gray-darker"
      >{{ formattedSuffix }}</span>
    </p>

    <p class="mt-4 pt-4 mb-2 text-xl border-t text-center mx-4v">
      {{ label }}
    </p>

    <div class="flex items-center">
      <p class="text-gray-darker font-bold flex items-center">
        <svg
          v-if="increaseOrDecrease < 0"
          xmlns="http://www.w3.org/2000/svg"
          height="24"
          viewBox="0 0 24 24"
          width="24"
          class="fill-current text-danger-dark mr-2 block"
        >
          <path d="M16 18l2.29-2.29-4.88-4.88-4 4L2 7.41 3.41 6l6 6 4-4 6.3 6.29L22 12v6z" />
        </svg>
        <svg
          v-if="increaseOrDecrease > 0"
          xmlns="http://www.w3.org/2000/svg"
          height="24"
          viewBox="0 0 24 24"
          width="24"
          class="fill-current text-success-dark mr-2"
        >
          <path d="M16 6l2.29 2.29-4.88 4.88-4-4L2 16.59 3.41 18l6-6 4 4 6.3-6.29L22 12V6z" />
        </svg>

        <span v-if="increaseOrDecrease != 0">
          <span v-if="growthPercentage !== 0">
            {{ growthPercentage }}%
          </span>

          <span v-else>No Increase</span>
        </span>

        <span v-else>
          <span v-if="previous == '0' && value != '0'">No Prior Data </span>
          <span v-if="value == '0' && previous != '0'">No Current Data</span>
          <span v-if="value == '0' && previous == '0'">No Data</span>
        </span>
      </p>
    </div>
  </div>
</template>

<script>
import numbro from 'numbro';
import singularOrPlural from '@/util/singularOrPlural';

export default {
  props: {
    data: {
      type: Object,
      required: true
    },
    prefix: {
      type: String,
      default: ''
    },
    suffix: {
      type: String,
      default: ''
    },
    format: {
      type: String,
      default: '(0[.]00a)',
    },
    label: {
      type: String,
      required: true
    }
  },

  computed: {
    growthPercentage () {
      return Math.abs(this.increaseOrDecrease);
    },

    previous () {
      return this.data ? this.data.previous : 0;
    },

    value () {
      return this.data ? this.data.current : 0;
    },

    increaseOrDecrease () {
      if (this.previous == 0 || this.previous == null || this.value == 0) {return 0;}
      return (((this.value - this.previous) / this.previous) * 100).toFixed(2);
    },

    sign () {
      let sign;
      switch (Math.sign(this.increaseOrDecrease)) {
        case 1:
          sign = '+';
          break;
        case 0:
          sign = '';
          break;
        case -1:
          sign = '-';
          break;
      }
      return sign;
    },

    isNullValue () {
      return this.value == null;
    },

    formattedValue () {
      if (!this.isNullValue) {
        return this.prefix + numbro(this.value).format(this.format);
      }

      return '';
    },

    formattedSuffix () {
      return singularOrPlural(this.value, this.suffix);
    },
  },

  methods: {
    handleChange (event) {
      this.$emit('selected', event.target.value);
    },
  },
};
</script>
