module.exports = function (eleventyConfig) {
  eleventyConfig.addPassthroughCopy("assets");
  eleventyConfig.addPassthroughCopy(".well-known");
  eleventyConfig.addPassthroughCopy("CNAME");
  eleventyConfig.addPassthroughCopy(".nojekyll");
  eleventyConfig.addPassthroughCopy("app-ads.txt");
  eleventyConfig.addPassthroughCopy("robots.txt");
  // Keep this Markdown source outside Eleventy's njk-only template inputs.
  eleventyConfig.addPassthroughCopy({ "markdown/index.md": "index.md" });

  return {
    dir: {
      includes: "_includes"
    },
    templateFormats: ["njk"],
    htmlTemplateEngine: "njk",
    markdownTemplateEngine: "njk"
  };
};
