<template>
  <div :class="classes">%FILE%</div>
</template>

<script>

const prefixCls = 'vi-%FILE%'

export default {
  name: 'vi-%FILE%',
  data() {
    return {}
  },
  props: {},
  methods: {},
  watch: {},
  created() {},
  mounted() {},
  computed: {
    classes() {
      return [
        `${ prefixCls }`
      ]
    }
  },
  components: {}
}
</script>

<style lang="scss" rel="stylesheet/scss">
  $-prefix-cls: 'vi-%FILE%';
  .#{$-prefix-cls} {
  }
</style>
<!-- vim: set ft=vue ff=unix et sw=2 ts=2 sts=2 tw=180: -->

