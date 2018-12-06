<template>
  <div>
    <!-- Validation Errors -->
    <div v-if="errors.length > 0" class="row">
      <div class="col-6 alert alert-danger">
        <strong>Whoops!</strong> Something went wrong. <br /><br />

        <!-- Error Listing -->
        <ul style="margin-bottom: 0;">
          <li v-for="(error, index) in errors" :key="index">{{ error }}</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    errors: {
      default() {
        return [];
      },
      type: Object
    }
  }
};
</script>
