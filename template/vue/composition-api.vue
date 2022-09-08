<template>
  <div :class="classes">
    
  </div>
</template>

<script lang="ts">
  import { defineComponent, computed } from '@nuxtjs/composition-api'

  const prefixCls = 'vi-${NAME}'

  export default defineComponent({
    fetchOnServer: false,
    middleware: 'auth',

    setup () {

      const classes = computed(() => {
        return [
          `${ prefixCls }`
        ]
      })

      return { classes }
    },
  })
</script>
<style lang="scss" rel="stylesheet/scss">
  $-prefix-cls: "vi-${NAME}";
  .#{$-prefix-cls} {
  }
</style>
