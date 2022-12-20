import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:dolbo_app/models/models.dart';
import 'package:dolbo_app/sizes.dart';
import 'package:dolbo_app/routes.dart';
import 'package:dolbo_app/providers/platform_provider.dart';
import 'package:dolbo_app/const/colors.dart';
import 'package:dolbo_app/services/encrypted_storage_service.dart';
import './like_element.dart';

class LikeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LikeView();
}

class _LikeView extends State<LikeView> {
  List<DolboModel> _myDolboList = [];
  bool _isEditting = false;
  late Future<List<DolboModel>> _future;
  final _encryptedStorageService = EncryptedStorageService();

  @override
  void initState() {
    super.initState();
    _initStorage();
    _future = _fetchMyDolboList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _initStorage() async {
    await _encryptedStorageService.initStorage();
  }

  Future<List<DolboModel>> _fetchMyDolboList() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    setState(() {
      _myDolboList = platformProvider.myDolboList;
    });
    return _myDolboList;
  }

  void _onDeleteItem(int index) async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    setState(() => _myDolboList.removeAt(index));
    platformProvider.myDolboList = _myDolboList;
    platformProvider.myDolboListNum = _myDolboList.length;
    await _encryptedStorageService.saveData(
        'list_num', (_myDolboList.length).toString());
    await _encryptedStorageService.removeData('element_$index');
    await _encryptedStorageService.readAll();
  }

  @override
  Widget build(BuildContext context) {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromRGBO(239, 239, 239, 1),
        appBar: PreferredSize(
            preferredSize: Size(context.pWidth, context.pHeight * 0.06),
            child: AppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: MyColors.fontColor,
                        size: context.pHeight * 0.035),
                    onPressed: () => Navigator.pop(context)),
                title: _appBar(),
                elevation: 0)),
        body: FutureBuilder(
            future: _future,
            builder: (BuildContext context,
                AsyncSnapshot<List<DolboModel>> snapshot) {
              if (snapshot.data != null) {
                return Column(children: [
                  Padding(padding: EdgeInsets.all(context.pHeight * 0.01)),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(Routes.HOME, arguments: 0);
                      },
                      child: LikeElement(
                          dolboData: platformProvider.defualtDolbo,
                          isEditting: false,
                          onDelete: null)),
                  _likeList(snapshot.data!),
                  _moveToMapButton(),
                ]);
              } else {
                return SizedBox();
              }
            }));
  }

  Widget _appBar() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const SizedBox(),
      Text('관심 돌보',
          style: TextStyle(
              color: MyColors.fontColor,
              fontSize: context.pHeight * 0.03,
              fontWeight: FontWeight.bold)),
      GestureDetector(
          onTap: () => setState(() => _isEditting = !_isEditting),
          child: Text(_isEditting ? '완료' : '편집',
              style: TextStyle(
                  color: MyColors.fontColor,
                  fontSize: context.pHeight * 0.027)))
    ]);
  }

  Widget _likeList(List<DolboModel> dolboList) {
    return SizedBox(
        height: context.pHeight * 0.54,
        width: context.pWidth,
        child: ReorderableListView(
            shrinkWrap: true,
            scrollController: null,
            buildDefaultDragHandles: _isEditting,
            children: List.generate(
                dolboList.length,
                (index) => _isEditting
                    ? ShakeWidget(
                        key: Key('$index'),
                        shakeConstant: ShakeLittleConstant2(),
                        autoPlay: true,
                        duration: const Duration(milliseconds: 2500),
                        child: LikeElement(
                          dolboData: dolboList[index],
                          isEditting: _isEditting,
                          onDelete: () => _onDeleteItem(index),
                        ))
                    : GestureDetector(
                        key: Key('$index'),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(Routes.HOME, arguments: index + 1);
                        },
                        child: LikeElement(
                          dolboData: dolboList[index],
                          isEditting: _isEditting,
                          onDelete: () => _onDeleteItem(index),
                        ))),
            onReorder: (int oldIndex, int newIndex) async {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final DolboModel item = _myDolboList.removeAt(oldIndex);
                _myDolboList.insert(newIndex, item);
              });
              _reorderStorage();
            }));
  }

  void _reorderStorage() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.myDolboListNum = _myDolboList.length;
    _myDolboList.asMap().forEach((index, element) async {
      await _encryptedStorageService.saveData(
          'element_$index', element.id.toString());
    });
  }

  Widget _moveToMapButton() {
    return Padding(
        padding: EdgeInsets.only(
          top: context.pHeight * 0.05,
          bottom: context.pHeight * 0.05,
          left: context.pWidth * 0.03,
          right: context.pWidth * 0.03,
        ),
        child: GestureDetector(
            onTap: () => _isEditting
                ? null
                : Navigator.of(context)
                    .pushNamed(Routes.MAP)
                    .then((_) => _fetchMyDolboList()),
            child: Container(
                height: context.pHeight * 0.07,
                padding: EdgeInsets.all(context.pHeight * 0.01),
                decoration: BoxDecoration(
                    color: _isEditting ? Colors.grey : const Color(0xFF1F4C9A),
                    borderRadius: BorderRadius.circular(context.pWidth * 0.02)),
                alignment: Alignment.center,
                child: Text('관심 돌보 추가하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: context.pWidth * 0.05,
                    )))));
  }
}
