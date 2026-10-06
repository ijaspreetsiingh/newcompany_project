import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

/// nest. `.address-card` (reference: designnew AddressesScreen)
class AddressWidget extends StatelessWidget {
  final AddressModel address;
  final bool fromAddress;
  final bool fromCheckout;
  final Function()? onRemovePressed;
  final Function()? onEditPressed;
  final Function()? onTap;
  final String? selectedUserAddressId;
  final Color? backgroundColor;
  final bool? isShowOnlyEdit;

  const AddressWidget({
    super.key,
    required this.address,
    required this.fromAddress,
    this.onRemovePressed,
    this.onEditPressed,
    this.backgroundColor,
    this.onTap,
    this.fromCheckout = false,
    this.selectedUserAddressId,
    this.isShowOnlyEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected =
        selectedUserAddressId != null && selectedUserAddressId == address.id;

    final IconData icon = switch ((address.addressLabel ?? 'others').toLowerCase()) {
      'home' => Icons.home_outlined,
      'office' || 'work' => Icons.work_outline_rounded,
      'other' || 'others' => Icons.location_on_outlined,
      _ => Icons.location_on_outlined,
    };

    final String contactName = (address.contactPersonName ?? '').trim();
    final String contactPhone = (address.contactPersonNumber ?? '').trim();
    final String contactLine = [contactName, contactPhone]
        .where((e) => e.isNotEmpty)
        .join(' Â· ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: NestInk.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? NestInk.primary : NestInk.border,
                width: isSelected ? 1.4 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NestIconWell(icon: icon),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (address.addressLabel ?? 'others').toString().tr,
                        style: NestInk.display(size: 12, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.address ?? '',
                        style: NestInk.body(
                          size: 9,
                          color: NestInk.mutedText,
                          height: 1.5,
                        ),
                      ),
                      if (contactLine.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          contactLine,
                          style: NestInk.body(
                            size: 9,
                            color: NestInk.mutedText,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 11),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (onEditPressed != null)
                      _ActionButton(
                        label: 'EDIT',
                        color: NestInk.primary,
                        onTap: onEditPressed,
                      ),
                    if (onRemovePressed != null &&
                        address.id != null &&
                        !isSelected) ...[
                      const SizedBox(height: 8),
                      _ActionButton(
                        label: 'DELETE',
                        color: NestInk.danger,
                        onTap: onRemovePressed,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Text(
          label,
          style: NestInk.display(size: 9, weight: FontWeight.w800, color: color),
        ),
      ),
    );
  }
}



