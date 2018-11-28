<template>
  <div>
    <h3>Pages</h3>
    <ul>
      <li
        v-for="page in pages"
        :key="page.key">
        <router-link
          :to="{
            name: 'page_detail',
            params: {
              pageKey: page.key
            }
        }">
          {{ page.title }}
        </router-link>
      </li>
    </ul>
  </div>
</template>


<script>
export default {
  data() {
    return {
      pages: []
    };
  },

  mounted() {
    this.initializePages();
  },

  methods: {
    async initializePages() {
      let response = await ExTeal.request().get("/plugins/pages");
      this.pages = response.data;
    }
  }
};
</script>
