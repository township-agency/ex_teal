<template>
  <default-field :field="field" :errors="errors">
    <template slot="field">
      <div class="mb-4">
        <input
          :id="addressId('address')"
          v-model="value.address"
          placeholder="Address"
          type="search"
          class="w-full form-control form-input form-input-bordered"
        />
      </div>
      <div class="mb-4">
        <input
          :id="addressId('address_line-2')"
          v-model="value.address_line_2"
          placeholder="Address Line 2"
          type="text"
          class="w-full form-control form-input form-input-bordered"
        />
      </div>
      <div class="mb-4">
        <input
          :id="addressId('company')"
          v-model="value.company"
          placeholder="Company"
          type="text"
          class="w-full form-control form-input form-input-bordered"
        />
      </div>
      <div class="mb-4 flex">
        <div class="city mr-2">
          <input
            :id="addressId('city')"
            v-model="value.city"
            placeholder="City"
            type="text"
            class="w-full form-control form-input form-input-bordered"
          />
        </div>
        <div class="state mx-2 flex-1">
          <select
            :id="addressId('state')"
            v-model="value.state"
            class="w-full form-control form-select"
          >
            <option value="" selected disabled> Choose a State </option>

            <option
              v-for="(value, key) in states"
              :key="key"
              :value="key"
              :selected="key == value.abbr"
            >
              {{ value.name }}
            </option>
          </select>
        </div>
        <div class="zip ml-2 flex-1">
          <input
            :id="addressId('zip')"
            v-model="value.zip"
            :class="errorClasses"
            placeholder="Zip Code"
            type="text"
            class="w-full form-control form-input form-input-bordered"
          />
        </div>
      </div>
    </template>
  </default-field>
</template>

<script>
import { HandlesValidationErrors } from "@/mixins";
import _ from "lodash";
import places from "places.js";
import states from "@/util/us-states";

let defaultValue = {
  address: "",
  address_line_2: "",
  city: "",
  company: "",
  country: "US",
  state: "",
  zip: ""
};

export default {
  mixins: [HandlesValidationErrors],
  props: {
    resourceName: {
      type: String,
      required: true
    },
    field: {
      type: Object,
      default() {
        return {};
      }
    }
  },

  data: () => {
    return {
      value: defaultValue,
      states: []
    };
  },

  /**
   * Mount the component.
   */
  mounted() {
    this.field.fill = this.fill;
    this.setInitialValue();

    ExTeal.$on(this.field.attribute + "-value", value => {
      this.value = value;
    });

    this.initializePlaces();
    this.states = states;
  },

  methods: {
    /*
     * Set the initial value for the field
     */
    setInitialValue() {
      this.value = this.field.value || defaultValue;
    },

    /**
     * Initialize Algolia places library.
     */
    initializePlaces() {
      const config = {
        container: document.querySelector(
          "#" + this.field.attribute + "-address"
        ),
        type: "address",
        templates: {
          value(suggestion) {
            return suggestion.name;
          }
        }
      };

      if (this.field.countries) {
        config.countries = this.field.countries;
      }

      const placesAutocomplete = places(config);

      placesAutocomplete.on("change", e => {
        this.$nextTick(() => {
          this.value = {
            address: e.suggestion.name,
            address_line_2: "",
            city: e.suggestion.city,
            state: this.parseState(
              e.suggestion.administrative,
              e.suggestion.countryCode
            ),
            zip: e.suggestion.postcode,
            country: e.suggestion.countryCode.toUpperCase()
          };
        });
      });

      placesAutocomplete.on("clear", () => {
        this.$nextTick(() => {
          this.value = defaultValue;
        });
      });
    },

    /**
     * Parse the selected state into an abbreviation if possible.
     */
    parseState(state, countryCode) {
      if (countryCode != "us") {
        return state;
      }

      return _.find(this.states, s => {
        return s.name == state;
      }).abbr;
    },

    addressId(val) {
      return this.field.attribute + "-" + val;
    },

    /**
     * Provide a function that fills a passed FormData object with the
     * field's internal value attribute
     */
    fill(form) {
      return (form[this.field.attribute] = this.value || defaultValue);
    }
  }
};
</script>

<style scoped>
.city {
  flex: 2;
}
</style>
