import { expect } from "chai";
import { shallowMount } from "@vue/test-utils";
import LayoutSideNav from "@/components/LayoutSideNav.vue";

describe("LayoutSideNav.vue", () => {
  it("renders props.resources when passed", () => {
    const resources = [
      { uri: "projects", singular: "project", title: "Projects" }
    ];
    const wrapper = shallowMount(LayoutSideNav, {
      stubs: ["router-link"],
      propsData: { config: { resources } }
    });
    expect(wrapper.text()).to.include("Projects");
  });
});
