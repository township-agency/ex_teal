<template>
  <div class="flex items-center justify-center p-6">
    <div class="flex items-center w-error">
      <div>
        <h1 class="text-error-title font-normal mb-1">403</h1>
        <p class="text-error-subtitle mb-6">Hold Up!</p>
        <p class="text-error-message mb-8 leading-normal">
          Someone has told us you don't belong here.
        </p>
        <router-link
          :to="{ name: 'home' }"
          class="dim btn btn-lg btn-default btn-white text-90 no-text-shadow tracking-wide uppercase"
        >
          Go Home
        </router-link>
      </div>
    </div>
  </div>
</template>
