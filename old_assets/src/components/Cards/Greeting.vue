<template>
  <div class="card p-4">
    <div class="flex gap-x-4">
      <div
        v-if="avatarUrl"
        class="flex-shrink-0 flex flex-col justify-center"
      >
        <img
          :src="avatarUrl"
          class="h-16 w-16 rounded-full"
        >
      </div>
      <div class="flex-grow">
        <p
          v-if="greeting"
          class="text-lg mb-1"
        >
          {{ greeting }}
        </p>
        <p
          v-if="userName"
          class="text-3xl leading-none"
        >
          {{ userName }}
        </p>
        <p
          v-if="userTitle"
          class="text-gray-darker mb-4"
        >
          {{ userTitle }}
        </p>
        <p
          v-if="helperText"
          v-html="helperText"
        />
      </div>
      <div
        v-if="links"
        class="flex-shrink-0"
      >
        <ul>
          <li
            v-for="(link, index) in links"
            :key="index"
            class="mb-2 last:mb-0 flex justify-end"
          >
            <a
              :href="link.url"
              :class="['btn', link.button_classes ? link.button_classes : 'btn-default btn-secondary']"
            >
              {{ link.label }}
            </a>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    card: {
      type: Object,
      required: true,
    },
  },

  computed: {
    options () {
      return this.card.options || {};
    },

    greeting () {
      return this.options.greeting;
    },

    userName () {
      return this.options.user_name;
    },

    userTitle () {
      return this.options.user_title;
    },

    avatarUrl () {
      return this.options.avatar_url;
    },

    helperText () {
      return this.options.helper_text;
    },

    links () {
      return this.options.links;
    }
  },
};
</script>
