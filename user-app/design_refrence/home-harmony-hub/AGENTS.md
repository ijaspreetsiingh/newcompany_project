<!-- LOVABLE:BEGIN -->
> [!IMPORTANT]
> This project is connected to [Lovable](https://lovable.dev). Avoid rewriting
> published git history — force pushing, or rebasing/amending/squashing commits
> that are already pushed — as it rewrites history on Lovable's side and the
> user will likely lose their project history.
>
> Commits you push to the connected branch sync back to Lovable and show up in
> the editor, so keep the branch in a working state.
<!-- LOVABLE:END -->

- Keep the customer journey in distinct TanStack routes with a shared in-memory booking context; this is a UI prototype and must not imply real booking persistence.
- Keep service display data in `src/lib/services.ts`; one catalog source ensures prices and descriptions agree across screens.
