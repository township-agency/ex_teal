<template>
  <div class="flex items-center justify-center p-6">
    <div class="flex items-center w-error">
      <div>
        <h1 class="text-error-title font-normal mb-1">404</h1>
        <p class="text-error-subtitle mb-6">Whoops&hellip;</p>
        <p class="text-error-message mb-8 leading-normal">
          The page you're trying to view doesn't exist
        </p>
        <router-link
          :to="{ name: 'home' }"
          class="btn btn-default btn-primary uppercase text-white"
        >
          Go Home
        </router-link>
      </div>
    </div>
  </div>
</template>
