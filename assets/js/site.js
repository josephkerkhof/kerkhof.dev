(() => {
  const STEP_VIEWPORT_RATIO = 0.25;
  const STEP_REPEAT_INTERVAL = 250;
  const rail = document.querySelector("[data-scroll-rail]");
  const track = rail?.querySelector("[data-scroll-track]");
  const thumb = rail?.querySelector("[data-scroll-thumb]");

  if (!rail || !track || !thumb) return;

  const upButton = rail.querySelector("[data-scroll-up]");
  const downButton = rail.querySelector("[data-scroll-down]");
  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  let maximumScroll = 0;
  let thumbTravel = 0;
  let thumbPosition = 0;
  let dragStartY = 0;
  let dragStartScroll = 0;
  let frameRequested = false;
  let stepRepeatInterval;

  const update = () => {
    const documentHeight = document.documentElement.scrollHeight;
    const viewportHeight = window.innerHeight;
    const trackHeight = track.clientHeight;
    maximumScroll = Math.max(0, documentHeight - viewportHeight);

    const thumbHeight = Math.max(
      24,
      Math.min(trackHeight, trackHeight * (viewportHeight / documentHeight)),
    );
    const progress = maximumScroll
      ? Math.max(0, Math.min(1, window.scrollY / maximumScroll))
      : 0;
    const percentage = Math.round(progress * 100);

    thumbTravel = trackHeight - thumbHeight;
    thumbPosition = thumbTravel * progress;
    thumb.style.height = `${thumbHeight}px`;
    thumb.style.transform = `translateY(${thumbPosition}px)`;
    thumb.setAttribute("aria-valuenow", String(percentage));
    thumb.setAttribute("aria-disabled", String(maximumScroll === 0));
    upButton.disabled = percentage === 0;
    downButton.disabled = percentage === 100 || maximumScroll === 0;
    frameRequested = false;
  };

  const requestUpdate = () => {
    if (!frameRequested) {
      frameRequested = true;
      requestAnimationFrame(update);
    }
  };

  const scrollByPage = (direction) => {
    window.scrollBy({
      top: direction * window.innerHeight * 0.8,
      behavior: reduceMotion.matches ? "auto" : "smooth",
    });
  };

  const scrollByStep = (direction) => {
    window.scrollBy({
      top: direction * window.innerHeight * STEP_VIEWPORT_RATIO,
      behavior: reduceMotion.matches ? "auto" : "smooth",
    });
  };

  const stopStepRepeat = () => {
    clearInterval(stepRepeatInterval);
  };

  const bindStepButton = (button, direction) => {
    button.addEventListener("pointerdown", (event) => {
      if (event.button !== 0) return;
      button.setPointerCapture(event.pointerId);
      scrollByStep(direction);
      stepRepeatInterval = setInterval(
        () => scrollByStep(direction),
        STEP_REPEAT_INTERVAL,
      );
    });
    button.addEventListener("click", (event) => {
      if (event.detail === 0) scrollByStep(direction);
    });
    button.addEventListener("pointerup", stopStepRepeat);
    button.addEventListener("pointercancel", stopStepRepeat);
    button.addEventListener("lostpointercapture", stopStepRepeat);
  };

  bindStepButton(upButton, -1);
  bindStepButton(downButton, 1);

  track.addEventListener("click", (event) => {
    if (event.target === thumb) return;
    const pointerPosition = event.clientY - track.getBoundingClientRect().top;
    scrollByPage(pointerPosition < thumbPosition ? -1 : 1);
  });

  thumb.addEventListener("pointerdown", (event) => {
    dragStartY = event.clientY;
    dragStartScroll = window.scrollY;
    thumb.setPointerCapture(event.pointerId);
    thumb.classList.add("is-dragging");
  });

  thumb.addEventListener("pointermove", (event) => {
    if (!thumb.hasPointerCapture(event.pointerId) || !thumbTravel) return;
    const scrollDelta =
      ((event.clientY - dragStartY) / thumbTravel) * maximumScroll;
    window.scrollTo({ top: dragStartScroll + scrollDelta, behavior: "auto" });
  });

  const stopDragging = (event) => {
    if (thumb.hasPointerCapture(event.pointerId)) {
      thumb.releasePointerCapture(event.pointerId);
    }
    thumb.classList.remove("is-dragging");
  };
  thumb.addEventListener("pointerup", stopDragging);
  thumb.addEventListener("pointercancel", stopDragging);

  thumb.addEventListener("keydown", (event) => {
    const actions = {
      ArrowUp: () => window.scrollBy(0, -40),
      ArrowDown: () => window.scrollBy(0, 40),
      PageUp: () => scrollByPage(-1),
      PageDown: () => scrollByPage(1),
      Home: () => window.scrollTo(0, 0),
      End: () => window.scrollTo(0, maximumScroll),
    };
    if (!actions[event.key]) return;
    event.preventDefault();
    actions[event.key]();
  });

  window.addEventListener(
    "scroll",
    () => {
      requestUpdate();
    },
    { passive: true },
  );
  window.addEventListener("resize", requestUpdate);
  new ResizeObserver(requestUpdate).observe(document.documentElement);
  update();
})();
