import 'package:demandium_provider/util/core_export.dart';


class BusinessReportShimmer extends StatelessWidget {
  const BusinessReportShimmer({super.key});

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: InkColors.card,
    borderRadius: BorderRadius.circular(19),
    border: Border.all(color: InkColors.border),
  );

  Widget _bar({double width = 60, double height = 10}) => Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: InkColors.secondary,
      borderRadius: BorderRadius.circular(6),
    ),
  );

  Widget _circle(double size) => Container(
    height: size,
    width: size,
    decoration:  BoxDecoration(
      color: InkColors.secondary,
      shape: BoxShape.circle,
    ),
  );

  Widget _tileSkeleton() => Container(
    height: 92,
    decoration: _cardDecoration,
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        _circle(34),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(width: 90, height: 14),
              const SizedBox(height: 6),
              _bar(width: 120, height: 10),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _kvSkeleton() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_bar(width: 96, height: 10), _bar(width: 64, height: 10)],
    ),
  );

  Widget _listRowSkeleton() => Container(
    width: double.infinity,
    decoration: _cardDecoration,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_bar(width: 84, height: 10), _bar(width: 56, height: 10)],
        ),
        const SizedBox(height: 18),
        _kvSkeleton(),
        _kvSkeleton(),
        _kvSkeleton(),
        const SizedBox(height: 8),
        Container(height: 1, color: InkColors.border),
        const SizedBox(height: 8),
        _kvSkeleton(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Shimmer(duration: const Duration(seconds: 2),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(children: [
            Expanded(child: _tileSkeleton()),
            const SizedBox(width: 12),
            Expanded(child: _tileSkeleton()),
          ]),
          const SizedBox(height: 12),

          Container(
            height: 320,
            width: double.infinity,
            decoration: _cardDecoration,
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _circle(34),
                const SizedBox(width: 12),
                _bar(width: 140, height: 12),
              ]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _circle(10),
                const SizedBox(width: 8),
                _bar(width: 56, height: 10),
                const SizedBox(width: 24),
                _circle(10),
                const SizedBox(width: 8),
                _bar(width: 56, height: 10),
              ]),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _bar(width: 14, height: 90),
                    _bar(width: 14, height: 130),
                    _bar(width: 14, height: 70),
                    _bar(width: 14, height: 150),
                    _bar(width: 14, height: 110),
                    _bar(width: 14, height: 60),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          for (int i = 0; i < 5; i++) ...[
            _listRowSkeleton(),
            if (i < 4) const SizedBox(height: 12),
          ],

        ]),
      ),
    );
  }
}
