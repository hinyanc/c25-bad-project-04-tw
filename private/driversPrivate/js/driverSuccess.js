window.onload = async () => {
  const urlSearchParams = new URLSearchParams(window.location.search);
  if (!urlSearchParams.has("oid")) {
    window.location = "/";
    return;
  }
};

document.querySelector(".return-btn").addEventListener("click", () => {
  console.log("hihihihi");
  window.location = "./driversMain.html"
})