import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PolicyViewerScreen extends StatefulWidget {
  const PolicyViewerScreen({super.key, this.title = 'Política', this.content});

  final String title;
  final Widget? content; // Conteúdo injetável (ex.: MarkdownBody)

  @override
  State<PolicyViewerScreen> createState() => _PolicyViewerScreenState();
}

class _PolicyViewerScreenState extends State<PolicyViewerScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _canScrollUp = false;
  bool _canScrollDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollChanged);
    // Inicializa flags após primeiro layout
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkScrollAvailability());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollChanged() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final maxScroll = pos.maxScrollExtent;
    final current = pos.pixels;

    final canUp = current > 0.0;
    final canDown = current < maxScroll;

    if (canUp != _canScrollUp || canDown != _canScrollDown) {
      setState(() {
        _canScrollUp = canUp;
        _canScrollDown = canDown;
      });
    }
  }

  void _checkScrollAvailability() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final canUp = pos.pixels > 0.0;
    final canDown = pos.pixels < pos.maxScrollExtent;

    setState(() {
      _canScrollUp = canUp;
      _canScrollDown = canDown;
    });
  }

  Future<void> _scrollPageUp() async {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final viewport = pos.viewportDimension;
    final target = (pos.pixels - viewport).clamp(0.0, pos.maxScrollExtent);
    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  Future<void> _scrollPageDown() async {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final viewport = pos.viewportDimension;
    final target = (pos.pixels + viewport).clamp(0.0, pos.maxScrollExtent);
    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _markAsRead() {
    // Comportamento padrão: retornar true para quem chamou
    Navigator.of(context).maybePop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // Regra obrigatória: nenhuma ação de scroll aqui
        actions: const <Widget>[],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Conteúdo base rolável
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // espaço p/ botão fixo
              child: widget.content ?? _DefaultLongPlaceholder(),
            ),

            // Botão fixo "Marcar como Lido"
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: ElevatedButton(
                onPressed: _markAsRead,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRose,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Marcar como Lido',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            // FAB subir
            if (_canScrollUp)
              Positioned(
                right: 16,
                top: 8,
                child: FloatingActionButton.small(
                  heroTag: 'scroll_up_overlay',
                  onPressed: _scrollPageUp,
                  tooltip: 'Mostrar conteúdo acima',
                  child: const Icon(Icons.arrow_upward),
                ),
              ),

            // FAB descer
            if (_canScrollDown)
              Positioned(
                right: 16,
                bottom: 88,
                child: FloatingActionButton.small(
                  heroTag: 'scroll_down',
                  onPressed: _scrollPageDown,
                  tooltip: 'Mostrar conteúdo abaixo',
                  child: const Icon(Icons.arrow_downward),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DefaultLongPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Política de Privacidade (Exemplo)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          List.generate(12, (i) =>
              'Parágrafo ${i + 1}: este é um conteúdo de exemplo para simular um documento longo. ').join('\n\n'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 16),
        // aumenta o tamanho para garantir rolagem
        const SizedBox(height: 1200),
      ],
    );
  }
}
