import 'dart:convert';
import 'package:http/http.dart' as http;

class DebankService {
  static const String _baseUrl = 'https://pro-openapi.debank.com/v1';
  final String _accessToken;
  final String _chainId;

  DebankService({
    required String accessToken,
    String chainId = 'eth',
  }) : _accessToken = accessToken, _chainId = chainId;

  /// Get user's complex tokens (DeFi protocol positions)
  Future<List<ProtocolData>> getUserComplexTokens(String walletAddress) async {
    final url = Uri.parse('$_baseUrl/user/complex_tokens?id=$walletAddress');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'AccessToken': _accessToken,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ProtocolData.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load complex tokens: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching complex tokens: $e');
    }
  }

  /// Get protocol positions with filtering and processing
  Future<ProtocolPositionsResponse> getProtocolPositions(String walletAddress) async {
    try {
      final complexTokens = await getUserComplexTokens(walletAddress);

      final protocols = complexTokens.map((protocol) {
        final totalValue = protocol.portfolioItemList.fold<double>(
          0.0,
          (sum, item) => sum + item.assetTokenList.fold<double>(
            0.0,
            (itemSum, asset) => itemSum + (asset.usdValue ?? 0.0),
          ),
        );

        return ProcessedProtocol(
          name: protocol.name,
          logoUrl: protocol.logoUrl,
          id: protocol.id,
          chainId: protocol.chain,
          totalValue: totalValue,
          formattedValue: '\$${totalValue.toStringAsFixed(0)}',
          portfolioItems: protocol.portfolioItemList
              .map((item) {
                final filteredAssets = item.assetTokenList
                    .where((asset) => (asset.usdValue ?? 0.0) >= 10000)
                    .map((asset) => ProcessedAsset(
                          symbol: asset.symbol ?? 'Unknown',
                          usdValue: asset.usdValue ?? 0.0,
                          formattedValue: '\$${(asset.usdValue ?? 0.0).toStringAsFixed(0)}',
                        ))
                    .toList();

                return ProcessedPortfolioItem(
                  name: item.name,
                  type: item.detailTypes.isNotEmpty ? item.detailTypes.first : 'unknown',
                  assets: filteredAssets,
                );
              })
              .where((item) => item.assets.isNotEmpty)
              .toList(),
        );
      }).toList();

      // Filter out protocols with total value below $10,000
      final filteredProtocols = protocols.where((protocol) => protocol.totalValue >= 10000).toList();

      final totalProtocolValue = filteredProtocols.fold<double>(
        0.0,
        (sum, protocol) => sum + protocol.totalValue,
      );

      // Add allocation percentages
      final protocolsWithAllocations = filteredProtocols.map((protocol) {
        final updatedPortfolioItems = protocol.portfolioItems.map((item) {
          final itemTotalValue = item.assets.fold<double>(
            0.0,
            (sum, asset) => sum + asset.usdValue,
          );
          final allocationPercentage = totalProtocolValue > 0 
              ? (itemTotalValue / totalProtocolValue) * 100 
              : 0.0;

          return ProcessedPortfolioItem(
            name: item.name,
            type: item.type,
            assets: item.assets,
            allocationPercentage: allocationPercentage,
          );
        }).toList();

        return ProcessedProtocol(
          name: protocol.name,
          logoUrl: protocol.logoUrl,
          id: protocol.id,
          chainId: protocol.chainId,
          totalValue: protocol.totalValue,
          formattedValue: protocol.formattedValue,
          portfolioItems: updatedPortfolioItems,
        );
      }).toList();

      // Flatten protocols into individual positions
      final positions = protocolsWithAllocations
          .expand((protocol) => protocol.portfolioItems.map((item) => Position(
                name: item.name,
                type: item.type,
                assets: item.assets,
                allocationPercentage: item.allocationPercentage ?? 0.0,
                protocol: ProtocolInfo(
                  name: protocol.name,
                  logoUrl: protocol.logoUrl,
                  id: protocol.id,
                  chainId: protocol.chainId,
                  totalValue: protocol.totalValue,
                  formattedValue: protocol.formattedValue,
                ),
              )))
          .toList()
        ..sort((a, b) => b.allocationPercentage.compareTo(a.allocationPercentage));

      return ProtocolPositionsResponse(
        chainId: _chainId,
        totalProtocols: protocolsWithAllocations.length,
        totalPositions: positions.length,
        totalValue: totalProtocolValue,
        formattedTotalValue: '\$${totalProtocolValue.toStringAsFixed(0)}',
        positions: positions,
      );
    } catch (e) {
      throw Exception('Error getting protocol positions: $e');
    }
  }
}

// Data Models
class ProtocolData {
  final String name;
  final String logoUrl;
  final String id;
  final String chain;
  final List<PortfolioItem> portfolioItemList;

  ProtocolData({
    required this.name,
    required this.logoUrl,
    required this.id,
    required this.chain,
    required this.portfolioItemList,
  });

  factory ProtocolData.fromJson(Map<String, dynamic> json) {
    return ProtocolData(
      name: json['name'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      id: json['id'] ?? '',
      chain: json['chain'] ?? '',
      portfolioItemList: (json['portfolio_item_list'] as List?)
          ?.map((item) => PortfolioItem.fromJson(item))
          .toList() ?? [],
    );
  }
}

class PortfolioItem {
  final String name;
  final List<String> detailTypes;
  final List<AssetToken> assetTokenList;

  PortfolioItem({
    required this.name,
    required this.detailTypes,
    required this.assetTokenList,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      name: json['name'] ?? '',
      detailTypes: (json['detail_types'] as List?)
          ?.map((type) => type.toString())
          .toList() ?? [],
      assetTokenList: (json['asset_token_list'] as List?)
          ?.map((asset) => AssetToken.fromJson(asset))
          .toList() ?? [],
    );
  }
}

class AssetToken {
  final String? symbol;
  final double? amount;
  final double? usdValue;

  AssetToken({
    this.symbol,
    this.amount,
    this.usdValue,
  });

  factory AssetToken.fromJson(Map<String, dynamic> json) {
    return AssetToken(
      symbol: json['symbol'],
      amount: json['amount']?.toDouble(),
      usdValue: json['usd_value']?.toDouble(),
    );
  }
}

// Processed Data Models
class ProcessedProtocol {
  final String name;
  final String logoUrl;
  final String id;
  final String chainId;
  final double totalValue;
  final String formattedValue;
  final List<ProcessedPortfolioItem> portfolioItems;

  ProcessedProtocol({
    required this.name,
    required this.logoUrl,
    required this.id,
    required this.chainId,
    required this.totalValue,
    required this.formattedValue,
    required this.portfolioItems,
  });
}

class ProcessedPortfolioItem {
  final String name;
  final String type;
  final List<ProcessedAsset> assets;
  final double? allocationPercentage;

  ProcessedPortfolioItem({
    required this.name,
    required this.type,
    required this.assets,
    this.allocationPercentage,
  });
}

class ProcessedAsset {
  final String symbol;
  final double usdValue;
  final String formattedValue;

  ProcessedAsset({
    required this.symbol,
    required this.usdValue,
    required this.formattedValue,
  });
}

class Position {
  final String name;
  final String type;
  final List<ProcessedAsset> assets;
  final double allocationPercentage;
  final ProtocolInfo protocol;

  Position({
    required this.name,
    required this.type,
    required this.assets,
    required this.allocationPercentage,
    required this.protocol,
  });
}

class ProtocolInfo {
  final String name;
  final String logoUrl;
  final String id;
  final String chainId;
  final double totalValue;
  final String formattedValue;

  ProtocolInfo({
    required this.name,
    required this.logoUrl,
    required this.id,
    required this.chainId,
    required this.totalValue,
    required this.formattedValue,
  });
}

class ProtocolPositionsResponse {
  final String chainId;
  final int totalProtocols;
  final int totalPositions;
  final double totalValue;
  final String formattedTotalValue;
  final List<Position> positions;

  ProtocolPositionsResponse({
    required this.chainId,
    required this.totalProtocols,
    required this.totalPositions,
    required this.totalValue,
    required this.formattedTotalValue,
    required this.positions,
  });
} 