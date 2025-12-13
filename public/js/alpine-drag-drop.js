/**
 * Alpine.js Drag and Drop Component
 * A Notion-style reorderable list implementation
 */
document.addEventListener('alpine:init', () => {
  Alpine.data('dragDropList', (config = {}) => ({
    // Configuration
    reorderUrl: config.reorderUrl || '',
    itemSelector: config.itemSelector || '[data-id]',
    handleSelector: config.handleSelector || '.drag-handle',

    // State
    draggingId: null,
    dragOverId: null,
    dragPosition: null, // 'before' or 'after'
    isDragging: false,
    dragElement: null,
    ghostElement: null,
    startY: 0,
    startX: 0,
    offsetY: 0,
    offsetX: 0,

    init() {
      this.$el.addEventListener('mousedown', (e) => this.handleMouseDown(e));
      document.addEventListener('mousemove', (e) => this.handleMouseMove(e));
      document.addEventListener('mouseup', (e) => this.handleMouseUp(e));

      // Touch support
      this.$el.addEventListener('touchstart', (e) => this.handleTouchStart(e), { passive: false });
      document.addEventListener('touchmove', (e) => this.handleTouchMove(e), { passive: false });
      document.addEventListener('touchend', (e) => this.handleTouchEnd(e));
    },

    getItemFromEvent(e) {
      const target = e.target.closest(this.itemSelector);
      return target;
    },

    getHandleFromEvent(e) {
      return e.target.closest(this.handleSelector);
    },

    handleMouseDown(e) {
      const handle = this.getHandleFromEvent(e);
      if (!handle) return;

      const item = this.getItemFromEvent(e);
      if (!item) return;

      e.preventDefault();
      this.startDrag(item, e.clientX, e.clientY);
    },

    handleTouchStart(e) {
      const handle = this.getHandleFromEvent(e);
      if (!handle) return;

      const item = this.getItemFromEvent(e);
      if (!item) return;

      const touch = e.touches[0];
      this.startDrag(item, touch.clientX, touch.clientY);
    },

    startDrag(item, clientX, clientY) {
      this.draggingId = item.dataset.id;
      this.dragElement = item;
      this.isDragging = true;

      const rect = item.getBoundingClientRect();
      this.startX = clientX;
      this.startY = clientY;
      this.offsetX = clientX - rect.left;
      this.offsetY = clientY - rect.top;

      // Add dragging class to original element
      item.classList.add('is-dragging');
      document.body.classList.add('is-drag-active');

      // Create ghost element
      this.createGhost(item, clientX, clientY);
    },

    createGhost(item, clientX, clientY) {
      const ghost = item.cloneNode(true);
      ghost.classList.add('drag-ghost');
      ghost.classList.remove('is-dragging');
      ghost.style.position = 'fixed';
      ghost.style.width = `${item.offsetWidth}px`;
      ghost.style.left = `${clientX - this.offsetX}px`;
      ghost.style.top = `${clientY - this.offsetY}px`;
      ghost.style.pointerEvents = 'none';
      ghost.style.zIndex = '9999';

      document.body.appendChild(ghost);
      this.ghostElement = ghost;
    },

    handleMouseMove(e) {
      if (!this.isDragging) return;
      e.preventDefault();
      this.updateDrag(e.clientX, e.clientY);
    },

    handleTouchMove(e) {
      if (!this.isDragging) return;
      e.preventDefault();
      const touch = e.touches[0];
      this.updateDrag(touch.clientX, touch.clientY);
    },

    updateDrag(clientX, clientY) {
      // Update ghost position
      if (this.ghostElement) {
        this.ghostElement.style.left = `${clientX - this.offsetX}px`;
        this.ghostElement.style.top = `${clientY - this.offsetY}px`;
      }

      // Find the item we're hovering over
      const items = Array.from(this.$el.querySelectorAll(this.itemSelector));
      let targetItem = null;
      let position = null;

      for (const item of items) {
        if (item.dataset.id === this.draggingId) continue;

        const rect = item.getBoundingClientRect();
        const midY = rect.top + rect.height / 2;

        if (clientY >= rect.top && clientY <= rect.bottom) {
          targetItem = item;
          position = clientY < midY ? 'before' : 'after';
          break;
        }
      }

      // Also check if we're above the first item or below the last
      if (!targetItem && items.length > 0) {
        const firstItem = items.find(i => i.dataset.id !== this.draggingId);
        const lastItem = [...items].reverse().find(i => i.dataset.id !== this.draggingId);

        if (firstItem) {
          const firstRect = firstItem.getBoundingClientRect();
          if (clientY < firstRect.top) {
            targetItem = firstItem;
            position = 'before';
          }
        }

        if (lastItem && !targetItem) {
          const lastRect = lastItem.getBoundingClientRect();
          if (clientY > lastRect.bottom) {
            targetItem = lastItem;
            position = 'after';
          }
        }
      }

      // Update drop indicator
      this.clearDropIndicators();

      if (targetItem && position) {
        this.dragOverId = targetItem.dataset.id;
        this.dragPosition = position;
        targetItem.classList.add(`drop-${position}`);
      } else {
        this.dragOverId = null;
        this.dragPosition = null;
      }
    },

    handleMouseUp(e) {
      if (!this.isDragging) return;
      this.endDrag();
    },

    handleTouchEnd(e) {
      if (!this.isDragging) return;
      this.endDrag();
    },

    endDrag() {
      if (this.dragOverId && this.dragPosition && this.draggingId !== this.dragOverId) {
        this.reorderItems();
      }

      this.cleanup();
    },

    reorderItems() {
      const items = Array.from(this.$el.querySelectorAll(this.itemSelector));
      const draggedItem = items.find(i => i.dataset.id === this.draggingId);
      const targetItem = items.find(i => i.dataset.id === this.dragOverId);

      if (!draggedItem || !targetItem) return;

      // Perform the DOM reorder
      if (this.dragPosition === 'before') {
        targetItem.parentNode.insertBefore(draggedItem, targetItem);
      } else {
        targetItem.parentNode.insertBefore(draggedItem, targetItem.nextSibling);
      }

      // Add animation class
      draggedItem.classList.add('just-dropped');
      setTimeout(() => {
        draggedItem.classList.remove('just-dropped');
      }, 300);

      // Send the new order to the server
      this.saveOrder();
    },

    saveOrder() {
      if (!this.reorderUrl) return;

      const items = Array.from(this.$el.querySelectorAll(this.itemSelector));
      const order = items.map(item => item.dataset.id);

      htmx.ajax('POST', this.reorderUrl, {
        values: { 'order[]': order },
        swap: 'none'
      });
    },

    clearDropIndicators() {
      const items = this.$el.querySelectorAll(this.itemSelector);
      items.forEach(item => {
        item.classList.remove('drop-before', 'drop-after');
      });
    },

    cleanup() {
      // Remove ghost
      if (this.ghostElement) {
        this.ghostElement.remove();
        this.ghostElement = null;
      }

      // Remove dragging class
      if (this.dragElement) {
        this.dragElement.classList.remove('is-dragging');
        this.dragElement = null;
      }

      document.body.classList.remove('is-drag-active');
      this.clearDropIndicators();

      // Reset state
      this.draggingId = null;
      this.dragOverId = null;
      this.dragPosition = null;
      this.isDragging = false;
    },

    destroy() {
      this.cleanup();
    }
  }));
});

