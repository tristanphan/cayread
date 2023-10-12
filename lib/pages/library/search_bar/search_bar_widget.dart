import 'package:cayread/common_widgets/modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:cayread/common_widgets/modal_bottom_sheet/modal_bottom_sheet_structures.dart';
import 'package:cayread/pages/library/library_page_actions.dart';
import 'package:cayread/pages/library/search_bar/book_search_delegate.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final LibraryPageActions _libraryPageActions;
  final bool _isLoading;

  const SearchBarWidget({
    super.key,
    required LibraryPageActions libraryPageActions,
    required bool isLoading,
  })  : _libraryPageActions = libraryPageActions,
        _isLoading = isLoading;

  void _openSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: BookSearchDelegate(context, hintText: _hintText),
    ).then((_) {
      if (context.mounted) _libraryPageActions.refreshLibrary();
    });
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ModalBottomSheet(
          header: ModalBottomSheetHeader(
            icon: const Icon(Icons.park_outlined),
            title: const Text("Cayread"),
            subtitle: const Text("App menu"),
          ),
          actions: [
            ModalBottomSheetAction(
              icon: const Icon(Icons.add),
              text: const Text("Import Book"),
              onPressed: () {
                _libraryPageActions.importBookAction();
                Navigator.pop(context, true);
              },
            ),
            ModalBottomSheetAction(
              icon: const Icon(Icons.settings),
              text: const Text("Settings"),
              onPressed: () {
                // TODO open settings
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _loadingIcon(BuildContext context) {
    IconThemeData iconTheme = IconTheme.of(context);
    return SizedBox(
      height: iconTheme.size,
      width: iconTheme.size,
      child: CircularProgressIndicator(color: iconTheme.color),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    BorderRadius cardRadius = BorderRadius.circular(10);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Card(
        elevation: 1.5,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
        child: InkWell(
          onTap: () => _openSearch(context),
          borderRadius: cardRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Search Icon
                Padding(
                  padding: const EdgeInsets.all(8.0).copyWith(right: 16.0),
                  child: const Icon(Icons.search),
                ),

                // Search Bar Label
                Expanded(
                  child: Text(
                    _hintText,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: theme.textTheme.bodyLarge!.color!.withOpacity(_hintTextOpacity),
                    ),
                  ),
                ),

                // Menu Button
                IconButton(
                  icon: _isLoading ? _loadingIcon(context) : const Icon(Icons.more_horiz),
                  onPressed: () => _openMenu(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String _hintText = "Search in Library";
const double _hintTextOpacity = 0.7;
