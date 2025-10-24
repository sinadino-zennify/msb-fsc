# LWC: Error Panel (daoErrorPanel)

Simple error display used by the container.

## daoErrorPanel.html (excerpt)
```html
<template>
  <template if:true={messages.length}>
    <div class="slds-box slds-theme_error slds-m-around_small">
      <ul class="slds-list_dotted">
        <template for:each={messages} for:item="m" for:index="idx">
          <li key={idx}>{m.message}</li>
        </template>
      </ul>
    </div>
  </template>
</template>
```

## daoErrorPanel.js (excerpt)
```js
import { LightningElement, api } from 'lwc';
export default class DaoErrorPanel extends LightningElement {
  @api messages = []; // [{message, field?}]
}
```
