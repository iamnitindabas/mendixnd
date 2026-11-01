# UI and Styling

**Purpose:** design Mendix pages as Mendix pages, not as HTML documents. The central rule is:
**Mendix object context is lexical, not DOM nesting.** The second is: **use widget design
properties before CSS classes.**

---

## 1. Page specification: a tree with contexts, not a screenshot

For every page, record:

```text
Page:             Module.Example_Detail
Layout:           Atlas_Core.Atlas_Default (or project layout)
Parameters:       Example (Module.Example), optional/required
Root DataView:    dvExample, entity Module.Example, source $Example
Nested contexts:  association path, entity, optionality, guard condition
Tabs:             parent tab container, tab page hierarchy
Grids:            name, entity, data source/XPath, sort, filters, paging, empty placeholder
Actions:          button name, caption, action, visibility mechanism, target page grant
Load-bearing:     widget/grid names used by exports, tests, navigation, grants
Responsive:       behaviour at 1440 / 1280 / 375 px
```

A screenshot is a reference, not a specification. "Match the prototype" is not a task.

---

## 2. Object context

### 2.1 `$currentObject` is "whatever encloses me"

A Data Grid's XPath is evaluated against the nearest enclosing DataView. `$currentObject`
means that DataView's entity. It is not a page-level global and it is not a URL parameter.

Consequences:

- Hoisting a filter DataView above nested tabs can change what `$currentObject` means and
  produce a type mismatch.
- A DataView may exist only to re-bind `$currentObject` so a grid XPath type-checks.
- The same token can mean three different entities on one page.
- A reader editing the Data tab cannot tell which entity `$currentObject/Tag` refers to unless
  the DataView is named and commented.

**Do:** name DataViews for what they hold (`dvResultTag`, `dvTrendFilter`), and put a
`-- Context:` comment on every re-binding DataView. Prefer explicit page/DataView parameters
where the platform allows. For long-lived pages, consider a view entity or a parameterized
DataView instead of a context trick.

### 2.2 Optional associations

To show a drill-through for an optional association:

```text
container linkedThing (Visible: $currentObject/Module.Assoc != empty) {
  dataview dvThing (DataSource: $currentObject/Module.Assoc) {
    actionbutton btnOpenThing (Action: show page Module.Thing_Detail(Thing = $currentObject))
  }
}
```

A button inside a DataView over an empty optional association **still renders**. Guard the
container, not only the button.

### 2.3 Page parameters are single objects

A page parameter is one object. Passing an association as a page argument may be accepted by
a static checker but fail the build or runtime. Bind the association in a DataView and pass
the DataView's object.

### 2.4 Inheritance and base grids

A grid over a base entity cannot reach subtype-only attributes. If the page needs a subtype
column, either put the shared column on the base, use a view entity, or use a subtype grid.
Do not promise a column the grid cannot bind.

---

## 3. Layout and styling

### 3.1 Design properties first

Use the widget's design properties for:

- spacing (margin/padding),
- flex direction,
- item gap,
- horizontal/vertical alignment,
- row wrap,
- typography/render mode,
- background/border where exposed.

A property name must come from the widget definition or the project's existing usage, not
from memory. A common failure is inventing `mx-spacing-*`, `gap-2`, or `mb-3`; they
did not exist in the compiled theme and silently did nothing.

### 3.2 Class audit

If a CSS class is genuinely required:

1. Prefer an official Atlas/theme utility.
2. Verify every token exists in the compiled stylesheet
   (`theme-cache/web/theme.compiled.css` or the project's equivalent).
3. Record why no design property exists.
4. Re-run the audit after the change: every `Class:` token used must be defined.

A class that exists but bypasses a design property is still a preference violation. Use
`RenderMode` for headings, flex properties for layout, and a class only for emphasis or a
genuinely missing capability.

### 3.3 Compound properties

Some design properties (for example `Spacing`) are compound values. A property-level `SET`
may not be able to write them; a widget replacement with the same name may be required.
Verify the tool's capability before planning a bulk property edit.

---

## 4. Grids

### 4.1 Width policy

For Data Grid 2 (verify the installed version):

- Set every data column to `Width: manual`.
- `Size` is a **relative weight**, not pixels.
- Set `MinWidth: minContent` as the phone guard.
- Sum the weights and compare with the target content width; a sum far above the viewport
  will scroll or squeeze.
- There is no per-column "hide on phone" property. If the design requires hiding a column,
  choose a different widget or layout at planning time.

### 4.2 Filters and data sources

- A dropdown filter on an association-path column needs its own `DataSource`; otherwise it can
  render "Unable to get filter store".
- A filter DataView placed above nested tabs may be instantiated once; inside a tab page it may
  be instantiated per tab. Place it deliberately.
- A microflow-datasource list may not refresh after a button action. Reopen the page or refresh
  the data source before asserting; do not assume the UI updated.
- Date filters over DateTime: `equal` is fragile when the stored value has a time component.
  Prefer `between` with day boundaries for date-only concepts.

### 4.3 Empty states

A single empty placeholder serves "no data" and "filtered to nothing" on many widgets. Write
copy that is true for all three cases:

1. **No data exists.**
2. **A filter hid all rows.**
3. **The reader lacks permission to see rows or perform the suggested action.**

The call to action must be one the reader can actually perform. If the button is granted to a
different role, either hide the sentence or use a capability-aware pair of texts.

### 4.4 Affordances

Do not ship a selection checkbox, bulk action, or filter whose consumer is deferred. A visible
affordance with no action is a lie. Leave the widget at its safe default until the action
exists.

---

## 5. Actions and page structure

### 5.1 Identity band

A detail page should identify the record before the actions:

- a header band with the record name/reference and status,
- record-level actions in the band,
- sections below, each with a clear title.

This prevents the record from being buried under buttons and gives every detail page one
recognizable structure.

### 5.2 Action beside the thing it changes

- Record-level actions (edit, complete, cancel, delete) in the header band.
- Section actions (add comment, edit narrative, toggle statistics) beside the section they
  affect.
- Do not put every action in one flat bar. If a bar exceeds a small number of controls, group
  it by purpose and separate destructive/administrative actions.

### 5.3 Conditional visibility

- A `call microflow` button may be hidden automatically when the user cannot execute the
  microflow; a `show page` button is **not** automatically hidden when the user cannot view the
  page. Check the target page grant and add `Visible:` or grant the page deliberately.
- A button inside an optional DataView needs the container guard (see §2.2).
- Visibility expressions should use a server-computed rights flag or a simple object
  property, not a role name or `[%CurrentUser%]` check scattered through the page.
- A group box with an empty collection still shows its title; add a visibility condition or
  an empty-state line if the section can be empty.

---

## 6. Navigation and reachability

For every page:

- Is it reachable from the menu, a `show page`, or a deliberate deep link?
- Does every parameterless menu page have a stable URL?
- Does every role that can see a `show page` button have view access to the target?
- Is there a role-specific home page, or is one home for all roles a deliberate decision?
- Are duplicate entry points to the same grid intentional and documented?
- Are pages with parameters (detail/edit) correctly excluded from the menu?

A page can have a grant and still be unusable because its actions are granted to a different
role. Check the **page × action × entity** triangle, not just page grants.

---

## 7. Reusable UI artifacts

### 7.1 Layouts

Use the project's existing layouts. A new layout is an architecture decision; it affects every
page and the theme. Do not swap layouts mid-project without a migration plan.

### 7.2 Snippets

Snippets are useful for repeated content, but a snippet may not accept arbitrary child widgets
and may not be the right tool for a page-specific layout. Verify the snippet's parameters and
content model before planning one. Do not introduce a snippet solely to avoid understanding a
layout.

### 7.3 Load-bearing names

Widget and grid names are interfaces when they are used by:

- Excel/CSV export nanoflows (bound by grid name),
- browser tests/selectors,
- page grants or navigation,
- documentation and handoff.

Freeze these names in the page spec. Search for references before renaming. A rename is a
migration, not a cleanup.

---

## 8. Responsive design

Define a contract at three viewports, for example:

| Viewport | Required behaviour |
|---|---|
| 1440 px | full layout, expected column count, no horizontal scroll |
| 1280 px | primary content fits; secondary columns may compress but not collapse to one |
| 375 px | readable stacking/cards; no seven-column squeeze; no horizontal overflow |

State what scrolls, what wraps, what hides, and which widget changes. "Responsive" is not a
property you add at the end; it is a page-design decision.

---

## 9. Rules

### MND-UI-01 — Specify pages as context trees, not screenshots

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** creating or restructuring a page.
- **Instruction:** Use the §1 template. Record every parameter, DataView, association path,
  optionality, tab parent, grid source, and action target.
- **Verify:** The page can be rebuilt from the spec; `describe page` matches the intended tree.

### MND-UI-02 — Respect lexical object context

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** nesting DataViews, tabs, grids, or filters.
- **Instruction:** Name DataViews by entity; comment re-bindings; do not assume
  `$currentObject` means the page parameter.
- **Verify:** Every grid XPath resolves against the intended entity; a reader can identify it.

### MND-UI-03 — Bind optional associations in a guarded DataView

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** a page offers drill-through to an optional association.
- **Instruction:** DataView over the association, container `Visible: <assoc> != empty`,
  button inside. Never pass the association as a page parameter.
- **Verify:** The button is absent when the association is empty; the build/runtime accepts the
  binding.

### MND-UI-04 — Check page-grant reachability for every `show page`

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** a button navigates to another page.
- **Instruction:** List the source roles and the target page grants. Add `Visible:` or grant
  the target deliberately. Do not rely on the platform to hide the button.
- **Verify:** A role-by-role reachability test; the lower role sees neither button nor content.

### MND-UI-05 — Use design properties, not remembered CSS classes

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** spacing, alignment, flex, typography, layout.
- **Instruction:** Use the widget property; verify the property name in the definition. If a
  class is necessary, grep the compiled theme and record why.
- **Verify:** Class audit (zero undefined tokens) and a screenshot/computed layout.

### MND-UI-06 — Define the grid width policy

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** adding or changing a data grid.
- **Instruction:** Manual width on every column, weights that fit the target, `minContent`,
  paging, filters, empty state, and a 375 px check. No per-column phone hide.
- **Verify:** Measured `grid-template-columns` and screenshot at 1440/1280/375.

### MND-UI-07 — Write empty states for three cases

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** a list/grid can be empty.
- **Instruction:** Cover no data, filtered-to-nothing, and no permission; make the call to
  action capability-aware.
- **Verify:** Filter to zero and check copy; test a lower role.

### MND-UI-08 — Put actions beside what they change

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** laying out a page with more than a few actions.
- **Instruction:** Identity band for record actions; section actions beside the section;
  group/separate administrative or destructive actions.
- **Verify:** A page review against the template; no flat 9-button bar.

### MND-UI-09 — Do not ship an affordance without its action

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** a selection/bulk/filter property is enabled.
- **Instruction:** Leave the widget at its safe default until the consumer exists.
- **Verify:** Every selection mode has a consuming action; every filter changes the result.

### MND-UI-10 — Make conditional sections self-explanatory

- **Type:** Universal
- **Priority:** P3
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** a group box/list can be empty.
- **Instruction:** Add visibility on the collection or an empty-state line.
- **Verify:** A fresh/empty record does not show a captioned empty box.

### MND-UI-11 — Treat widget and grid names as interfaces

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** renaming or restructuring a page.
- **Instruction:** Search for references (exports, tests, navigation, grants, docs) before
  renaming; update them in the same change.
- **Verify:** Export/test/navigation still works after the change.

### MND-UI-12 — Audit navigation and deep links

- **Type:** Universal
- **Priority:** P3
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** adding a menu item or a parameterless page.
- **Instruction:** Give menu pages stable URLs; decide role homes explicitly; record
  duplicate entry points; keep parameter-only pages out of the menu.
- **Verify:** Deep links open the right page; the menu matches the page inventory.

### MND-UI-13 — Verify responsive behaviour, not just DOM presence

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** any page is declared done.
- **Instruction:** Check 1440/1280/375; measure computed layout, overflow, column count,
  label/value separation, and tab visibility.
- **Verify:** Screenshots and measurements in the evidence; not a row-count assertion.

### MND-UI-14 — Keep filter/data-source placement deliberate

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** a filter DataView sits near tabs or nested grids.
- **Instruction:** Decide whether it is instantiated once or per tab; bind the filter to the
  intended entity; prefer `between` for date-time columns.
- **Verify:** Switch tabs and confirm the filter/grid still resolves to the intended context.

### MND-UI-15 — Use official Atlas/theme utilities only when no property exists

- **Type:** Universal
- **Priority:** P3
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** a design property genuinely does not exist.
- **Instruction:** Use a documented utility class; verify it in the compiled CSS; record the
  gap. Do not invent a utility name.
- **Verify:** Class audit and visual check.

### MND-UI-16 — Plan the page hierarchy before the widgets

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** translating a prototype or a written requirement into pages.
- **Instruction:** Decide layouts, tabs, repeated regions, group boxes, snippets, and action
  placement before writing widgets. Mark deliberate deviations and non-goals.
- **Verify:** A page tree reviewed against the requirement; no "match the prototype" task.
