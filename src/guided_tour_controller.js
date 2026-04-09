import { Controller } from '@hotwired/stimulus'
import { Tooltip } from "bootstrap"
import { Popover } from "bootstrap"

export default class extends Controller {
  // Define targets for the controller
  static targets = ["overlay", "explanation"];

  // Define values with types and defaults
  static values = {
    timeout: {type: Number, default: 1000},
    stepLineText: { type: String, default: "Step {{current}} of {{total}}" },
    nextBtnText: { type: String, default: "Next" },
    doneBtnText: { type: String, default: "Done!" },
    prevBtnText: { type: String, default: "Prev" }
  }

  /**
   * Creates a debounced version of a function
   * @param {Function} func - The function to debounce
   * @param {number} wait - The debounce delay in milliseconds
   * @returns {Function} The debounced function
   */
  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }

  /**
   * Initializes the controller when connected to the DOM
   * Sets up initial state, event listeners, and starts the guided-tour process
   */
  connect() {
    document.head.appendChild(this.styles);

    this.coordinates = [];
    this.currentPopover = null;
    this.currentExplanation = 0;
    this.totalSteps = this.explanationTargets.length;
    this.startButton = document.getElementById('guidedTourStarterBtn');

    // if there is no explanation receiver hide everything
    if (this.totalSteps <= this.currentExplanation) {
      if (this.startButton) {
        this.startButton.classList.add('d-none');
      }
      return
    }

    // Create debounced versions of navigation methods
    this.debouncedPrevious = this.debounce(() => this.previousExplanation(), 250);
    this.debouncedNext = this.debounce(() => this.nextExplanation(), 250);

    // Add keyboard event listener
    this.handleKeyPress = this.handleKeyPress.bind(this);
    document.addEventListener('keydown', this.handleKeyPress);

    // Configure custom allowlist for Bootstrap Popover
    this.myCustomAllowList = {
      ...Tooltip.Default.allowList,
      div: ['class'],
      h1: [],
      p: [],
      button: ['class'],
      '*': ['class']
    };

    // Set up demo button or start guidedTour automatically
    if (this.startButton) {
      console.log('Guided Tour: Button found');
      this.startButton.addEventListener('click', () => {
        this.initializeCoordinates();
        this.currentExplanation = -1;
        this.nextExplanation();
      });
    } else {
      setTimeout(() => {
        this.initializeCoordinates();
        this.showExplanation(this.currentExplanation);
      }, this.timeoutValue);
    }
  }

  /**
   * Cleanup when the controller is disconnected
   */
  disconnect() {
    document.removeEventListener('keydown', this.handleKeyPress);
  }

  /**
   * Handles keyboard events for navigation
   * @param {KeyboardEvent} event - The keyboard event
   */
  handleKeyPress(event) {
    // Only handle keyboard events when the tour is active
    if (!this.overlayTarget.classList.contains('active')) return;

    switch (event.key) {
      case 'ArrowLeft':
        this.debouncedPrevious();
        break;
      case 'ArrowRight':
        this.debouncedNext();
        break;
      case 'Escape':
        this.hideGuidedTour(); // Escape remains immediate
        break;
    }
  }


  /**
   * Calculates and stores the coordinates of each target element
   * These coordinates are used for positioning the overlay and popover
   */
  initializeCoordinates() {
    this.explanationTargets.forEach((target, _index) => {
      const explainThis = document.getElementById(target.dataset.targetElement);
      const rect = explainThis.getBoundingClientRect();
      const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;
      const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

      this.coordinates.push({
        top: rect.top + scrollTop - 5,
        left: rect.left + scrollLeft - 5,
        width: rect.width + 10,
        height: rect.height + 10,
        explanation: target
      });
    });
  }

  /**
   * Returns the configuration object for Bootstrap Popover
   * @returns {Object} Popover configuration
   */
  popoverConfig() {
    return {
      trigger: 'manual',
      customClass: 'guided-tour--popover',
      html: true,
      placement: 'auto',
      container: 'body',
      allowList: this.myCustomAllowList
    };
  }

  /**
   * Disposes of the current Popover instance if it exists
   */
  disposeCurrentPopover() {
    if (this.currentPopover) {
      this.currentPopover.dispose();
      this.currentPopover = null;
    }
  }

  /**
   * Navigates to the previous explanation step
   */
  previousExplanation() {
    if (this.currentExplanation <= 0) return;

    this.currentExplanation -= 1;
    this.showExplanation();
  }

  /**
   * Navigates to the next explanation step
   * Hides guided-tour if at the last step
   */
  nextExplanation() {
    if (this.currentExplanation >= this.coordinates.length - 1) this.hideGuidedTour();

    this.currentExplanation += 1;
    this.showExplanation();
  }

  /**
   * Displays the current step's explanation
   * Positions the overlay, creates and shows the Popover
   */
  showExplanation() {
    this.disposeCurrentPopover();

    if (this.currentExplanation <= this.coordinates.length) {
      const matchingCoordinate = this.coordinates[this.currentExplanation];
      this.overlayTarget.classList.add('active');
      this.overlayTarget.style.top = `${matchingCoordinate.top}px`;
      this.overlayTarget.style.left = `${matchingCoordinate.left}px`;
      this.overlayTarget.style.width = `${matchingCoordinate.width}px`;
      this.overlayTarget.style.height = `${matchingCoordinate.height}px`;
      this.content = matchingCoordinate.explanation.innerHTML;
      this.overlayTarget.dataset.bsContent = this.populatedTemplate;

      // Create a MutationObserver to watch for when the popover is added to the DOM
      const observer = new MutationObserver((mutations, obs) => {
        const popover = document.querySelector('.guided-tour--popover');
        if (popover) {
          this.bindPopoverEvents();
          obs.disconnect(); // Stop observing once we've found the popover
        }
      });

      // Start observing the document with the configured parameters
      observer.observe(document.body, {childList: true, subtree: true});

      setTimeout(() => {
        this.currentPopover = new Popover(this.overlayTarget, this.popoverConfig());
        this.currentPopover.show();

        // Create Intersection Observer to check top visibility
        const intersectionObserver = new IntersectionObserver((entries) => {
          const [entry] = entries;

          // Get the position of the element relative to the viewport
          const rect = entry.boundingClientRect;
          const isTopInView = rect.top >= 0 && rect.top <= window.innerHeight;

          if (!isTopInView) {
            this.overlayTarget.scrollIntoView({ behavior: 'smooth' });
          }

          intersectionObserver.disconnect();
        }, {
          threshold: [0, 1],
          rootMargin: "0px"
        });

        intersectionObserver.observe(this.overlayTarget);
      }, 300);
    } else {
      this.overlayTarget.classList.remove('active');
      console.error(`No matching explanation found for step: ${this.currentExplanation}`);
    }
  }

  /**
   * Hides the guided-tour overlay and disposes of the current Popover
   */
  hideGuidedTour() {
    this.disposeCurrentPopover();
    this.overlayTarget.classList.remove('active');
    this.overlayTarget.style.top = '0px';
    this.overlayTarget.style.left = '0px';
    this.overlayTarget.style.width = '0px';
    this.overlayTarget.style.height = '0px';
  }

  get stepLine() {
    return this.stepLineTextValue
      .replace('{{current}}', this.currentExplanation + 1)
      .replace('{{total}}', this.totalSteps);
  }

  /**
   * Returns the populated HTML template for the Popover content
   * @returns {string} Populated HTML template
   */
  get populatedTemplate() {
    return this.template
      .replace('{{stepLine}}', this.stepLine)
      .replace('{{totalSteps}}', this.totalSteps)
      .replace('{{prevButton}}', this.prevButton)
      .replace('{{nextButton}}', this.nextButton)
      .replace('{{content}}', this.content);
  }

  /**
   * Returns the HTML style tag with default styles
   * @returns {string} HTML style tag
   */
  get styles() {
    const styleElement = document.createElement('style');
    styleElement.textContent = `
    /* Animation keyframes for sliding and jiggling from bottom right */

    :root {
      --guided-tour-jiggle-offset: 25px;
    }

    @keyframes slideFromRight {
        0% {
            transform: translateX(100%);
            opacity: 0;
        }
        50% {
            transform: translateX(0);
            opacity: 1;
        }
        60% {
            transform: translateX(calc(var(--guided-tour-jiggle-offset) * -1));
        }
        70% {
            transform: translateX(var(--guided-tour-jiggle-offset));
        }
        80% {
            transform: translateX(calc(var(--guided-tour-jiggle-offset) * -1));
        }
        90% {
            transform: translateX(var(--guided-tour-jiggle-offset));
        }
        100% {
            transform: translateX(0);
            opacity: 1;
        }
    }

    .guided-tour--overlay {
        box-shadow: rgb(233 77 77 / 80%) 0 0 1px 2px,
        rgb(84 84 84 / 50%) 0 0 0 5000px;
        box-sizing: content-box;
        position: absolute;
        border-radius: 4px;
        transition: all .3s ease-out;
        z-index: 9998;
        pointer-events: none;
        opacity: 0;
    }

    .guided-tour--starter-btn-wrapper {
      position: absolute;
      right: 1rem;
      bottom: 1rem;
      animation: slideFromRight 1.2s cubic-bezier(0.23, 1, 0.32, 1) forwards;
      animation-delay: 1s;
      /* Ensures button is hidden before animation starts */
      opacity: 0;
      /* Improve animation performance */
      will-change: transform, opacity;

      > .btn {
        /* Prevent any layout shifts during animation */
        transform-origin: right center;
        z-index: 1000; /* Ensure button stays above other content */
      }
    }

    .guided-tour--overlay.active {
        opacity: 1;
    }

    .guided-tour--popover {
        z-index: 9999;
        max-width: 33.3%;
    }
  `
    return styleElement
  }

  /**
   * Returns the HTML template structure for the Popover content
   * @returns {string} HTML template
   */
  get template() {
    return `
      <div class="overlay-template">
        <div class="d-flex flex-row justify-content-between">
          <h3>{{stepLine}}</h3>
          <button type="button" class="btn-close guided-tour--close" aria-label="Close"></button>
        </div>
        <p class="fs-5">{{content}}</p>
        <div class="d-flex flex-row justify-content-between">
          {{prevButton}}
          {{nextButton}}
        </div>
      </div>
    `;
  }

  /**
   * Returns the HTML for the previous button, or an empty string if on the first step
   * @returns {string} Previous button HTML
   */
  get prevButton() {
    if (this.currentExplanation <= 0) return '';

    return `<button class="btn btn-secondary guided-tour--prev">${this.prevBtnTextValue}</button>`;
  }

  /**
   * Returns the HTML for the next button, or a "Done" button if on the last step
   * @returns {string} Next or Done button HTML
   */
  get nextButton() {
    if (this.currentExplanation >= this.coordinates.length - 1) {
      return `<button class="btn btn-primary guided-tour--finish">${this.doneBtnTextValue}</button>`;
    } else {
      return `<button class="btn btn-primary guided-tour--next">${this.nextBtnTextValue}</button>`;
    }
  }

  /**
   * Binds click events to the Popover navigation buttons
   */
  bindPopoverEvents() {
    const popoverElement = document.querySelector('.guided-tour--popover');
    if (popoverElement) {
      popoverElement.addEventListener('click', (event) => {
        if (event.target.classList.contains('guided-tour--prev')) {
          this.previousExplanation();
        } else if (event.target.classList.contains('guided-tour--next')) {
          this.nextExplanation();
        } else if (event.target.classList.contains('guided-tour--finish')) {
          this.hideGuidedTour();
        } else if (event.target.classList.contains('guided-tour--close')) {
          this.hideGuidedTour();
        }
      });
    }
  }
}
