import { expect } from "chai";
import { shallowMount } from "@vue/test-utils";
import LayoutTopNav from "@/components/LayoutTopNav.vue";

describe("LayoutTopNav.vue", () => {
  it("renders props.title when passed", () => {
    const title = "new title";
    const wrapper = shallowMount(LayoutTopNav, {
      propsData: { title, logo: "" }
    });
    expect(wrapper.html()).to.include(title);
  });

  it("renders props.logo when passed", () => {
    const logo = "/images/logo.svg";
    const wrapper = shallowMount(LayoutTopNav, {
      propsData: { logo }
    });
    expect(wrapper.html()).to.include(logo);
  });
});
