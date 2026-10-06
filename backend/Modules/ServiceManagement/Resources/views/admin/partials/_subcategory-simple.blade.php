@php
// Get all sub-categories grouped by parent
$allSubCategories = \Modules\CategoryManagement\Entities\Category::ofType('sub')->ofStatus(1)->orderBy('parent_id')->orderBy('name')->get();
@endphp

<select class="subcategory-select theme-input-style w-100" name="sub_category_id" id="sub-category-id" required>
    <option value="">-- Select Sub-Category --</option>
    @php
        $lastParent = null;
        $parentNames = \Modules\CategoryManagement\Entities\Category::ofType('main')->pluck('name', 'id');
    @endphp
    @foreach($allSubCategories as $subCat)
        @if($lastParent !== $subCat->parent_id)
            @if($lastParent !== null)
                </optgroup>
            @endif
            <optgroup label="{{ $parentNames[$subCat->parent_id] ?? 'Unknown' }}">
            @php $lastParent = $subCat->parent_id; @endphp
        @endif
        <option value="{{ $subCat->id }}">{{ $subCat->name }}</option>
    @endforeach
    @if($lastParent !== null)
        </optgroup>
    @endif
</select>
