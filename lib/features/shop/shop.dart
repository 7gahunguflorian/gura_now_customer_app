// Shop feature barrel file

// Domain
export 'domain/entities/product.dart';
export 'domain/entities/shop.dart';
export 'domain/repositories/shop_repository.dart';
export 'domain/usecases/get_shop_detail_usecase.dart';
export 'domain/usecases/get_shop_products_usecase.dart';
export 'domain/usecases/get_shops_usecase.dart';

// Data
export 'data/models/shop_model.dart';
export 'data/datasources/shop_remote_datasource.dart';
export 'data/repositories/shop_repository_impl.dart';

// Presentation
export 'presentation/bloc/shop_bloc.dart';
export 'presentation/pages/shop_detail_screen.dart';
