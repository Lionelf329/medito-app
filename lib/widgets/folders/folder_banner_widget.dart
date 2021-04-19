/*This file is part of Medito App.

Medito App is free software: you can redistribute it and/or modify
it under the terms of the Affero GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Medito App is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
Affero GNU General Public License for more details.

You should have received a copy of the Affero GNU General Public License
along with Medito App. If not, see <https://www.gnu.org/licenses/>.*/

import 'package:Medito/network/api_response.dart';
import 'package:Medito/network/folder/folder_bloc.dart';
import 'package:Medito/utils/colors.dart';
import 'package:Medito/utils/text_themes.dart';
import 'package:Medito/utils/utils.dart';
import 'package:Medito/widgets/app_bar_widget.dart';
import 'package:Medito/widgets/gradient_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FolderBannerWidget extends StatelessWidget {
  FolderBannerWidget({Key key, this.bloc}) : super(key: key);
  final FolderItemsBloc bloc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: bloc.primaryColorController.stream,
        builder: (context, snapshot) {
          return Container(
            color: MeditoColors.intoTheNight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    GradientWidget(
                      opacity: 0.24,
                      height: 168.0,
                      primaryColor: snapshot.hasData
                          ? parseColor(snapshot.data)
                          : MeditoColors.transparent,
                    ),
                    Column(
                      children: [
                        MeditoAppBarWidget(transparent: true),
                        Row(
                          children: [_getImageContainer(), _getTitleStream()],
                        ),
                      ],
                    ),
                  ],
                ),
                _getDescriptionWidget()
              ],
            ),
          );
        });
  }

  Widget _getImageContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: SizedBox(
          height: 96,
          width: 96,
          child: StreamBuilder<String>(
              stream: bloc.primaryColorController.stream,
              builder: (context, snapshot) {
                return Container(
                  color: snapshot.hasData
                      ? parseColor(snapshot.data)
                      : MeditoColors.intoTheNight,
                  padding: const EdgeInsets.all(12.0),
                  child: Stack(
                    children: [
                      _bgImageStream(),
                      _actualImageStream(),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  StreamBuilder<String> _getTitleStream() => StreamBuilder<String>(
      initialData: '',
      stream: bloc.titleController.stream,
      builder: (context, snapshot) {
        return Text(
          snapshot.data,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline1,
        );
      });

  StreamBuilder<ApiResponse<String>> _actualImageStream() {
    return StreamBuilder<ApiResponse<String>>(
        stream: bloc.coverController.stream,
        initialData: ApiResponse.loading(),
        builder: (context, snapshot) {
          switch (snapshot.data.status) {
            case Status.LOADING:
              return Center(
                child: SizedBox(
                    height: 24, width: 24, child: CircularProgressIndicator()),
              );
              break;

            case Status.COMPLETED:
              return getNetworkImageWidget(snapshot.data.body);
              break;
            case Status.ERROR:
              return Center(child: Icon(Icons.broken_image_outlined));
            default:
              return Container();
          }
        });
  }

  StreamBuilder<String> _bgImageStream() {
    return StreamBuilder<String>(
        stream: bloc.backgroundImageController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return getNetworkImageWidget(snapshot.data);
          } else {
            return Container();
          }
        });
  }

  Widget _getDescriptionWidget() {
    return StreamBuilder<String>(
        stream: bloc.descriptionController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20),
              child: Markdown(
                data: snapshot.data,
                padding: null,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                    .copyWith(
                    p: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 14.0)
                ),
                shrinkWrap: true,
              ),
            );
          } else {
            return Container();
          }
        });
  }
}